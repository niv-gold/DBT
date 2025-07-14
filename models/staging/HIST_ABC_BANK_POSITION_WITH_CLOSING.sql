{{ config(materialized='incremental') }}
WITH 
stg_input as( -- all data from source 
    SELECT
        i.* EXCLUDE(REPORT_DATE, QUANTITY, COST_BASE, POSITION_VALUE, LOAD_TS_UTC)
        ,REPORT_DATE
        ,QUANTITY
        ,COST_BASE
        ,POSITION_VALUE
        ,LOAD_TS_UTC
        ,false as CLOSED
    FROM {{ ref('STG_ABC_BANK_POSITION')}} as i
)
{% if is_incremental() -%} -- is target table exists
,current_from_history as( 
    {{current_from_history(
        history_rel = this,  
        key_column = 'POSITION_HKEY'
    )}}
),    
load_from_input as( -- source data with no change and open position
    SELECT
        i.* 
    FROM stg_input i LEFT JOIN current_from_history curr ON
        not curr.CLOSED
        AND i.POSITION_HDIFF = curr.POSITION_HDIFF
    WHERE curr.POSITION_HDIFF is null
),
closed_from_hist as(
    SELECT
        curr.* EXCLUDE(REPORT_DATE, QUANTITY, COST_BASE, POSITION_VALUE, LOAD_TS_UTC, CLOSED)
        ,(SELECT MAX(REPORT_DATE) FROM stg_input) as  REPORT_DATE
        ,0 as QUANTITY
        ,0 as COST_BASE
        ,0 as POSITION_VALUE
        ,'{{ run_started_at }}' AS LOAD_TS_UTC
        , true as CLOSED
    FROM current_from_history curr LEFT JOIN stg_input i ON
            curr.POSITION_HKEY = i.POSITION_HKEY
    WHERE not curr.CLOSED
        AND i.POSITION_HKEY is null
),
change_to_store as(
    SELECT * FROM load_from_input
    UNION all
    SELECT * FROM closed_from_hist
)
{%- else %} -- not incremental, full load.
, change_to_store as(
    SELECT * 
    FROM stg_input
)
{%- endif %}
SELECT * 
FROM change_to_store
