{{ config(materialized='ephemeral') }}

WITH source_records as(
    SELECT
         CITY as CITY -- TEXT
        ,OPEN_UTC as OPEN_UTC -- TEXT
        ,OPEN as OPEN -- TEXT
        ,ZONE as ZONE -- TEXT
        ,DST_PERIOD as DST_PERIOD -- TEXT
        ,CLOSE as CLOSE -- TEXT
        ,ID as ID -- TEXT
        ,LUNCH_UTC as LUNCH_UTC -- TEXT
        ,CLOSE_UTC as CLOSE_UTC -- TEXT
        ,NAME as NAME -- TEXT
        ,COUNTRY as COUNTRY -- TEXT
        ,DELTA as DELTA -- FLOAT
        ,LUNCH as LUNCH -- TEXT

        ,LOAD_TS as LOAD_TS  -- TIMESTAMP_NTZ
        ,'SEEDS.ABC_BANK_EXCHANGE_INFO' as RECORD_SOURCE -- TEXT
    FROM {{ source('seeds','ABC_BANK_EXCHANGE_INFO') }}
),
hashed as(
    SELECT
         *
        ,{{dbt_utils.surrogate_key(['ID'])}} as EXCHANGE_HKEY        
        ,{{dbt_utils.surrogate_key(['CITY','OPEN_UTC','OPEN','ZONE','DST_PERIOD','CLOSE','LUNCH_UTC','CLOSE_UTC','NAME',
            'COUNTRY','DELTA','LUNCH'])}} as EXCHANGE_HDIFF        
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', LOAD_TS) as LOAD_TS_UTC
    FROM source_records
),
default_record as (
    SELECT
         'Missing' as CITY
        ,'Missing' as OPEN_UTC
        ,'Missing' as OPEN
        ,'Missing' as ZONE
        ,'Missing' as DST_PERIOD
        ,'Missing' as CLOSE
        ,'Missing' as ID
        ,'Missing' as LUNCH_UTC
        ,'Missing' as CLOSE_UTC
        ,'Missing' as NAME
        ,'Missing' as COUNTRY
        ,NULL as DELTA
        ,'Missing' as LUNCH        
        ,'1900-01-01' as LOAD_TS
        ,'Missing' as RECORD_SOURCE   
        ,'-1' as EXCHANGE_HKEY  
        ,'-1' as EXCHANGE_HDIFF   
        ,'1900-01-01' as LOAD_TS_UTC
),
union_records as(
    SELECT * EXCLUDE LOAD_TS FROM hashed
    UNION
    SELECT * EXCLUDE LOAD_TS FROM default_record
)
SELECT *
FROM union_records