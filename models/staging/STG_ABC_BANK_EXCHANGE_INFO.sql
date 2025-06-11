{{ config(materialized='ephemeral') }}
{% set na = var('na', '∅') %}


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
pre_hash as(
    SELECT
         IFNULL(CITY,'{{na}}') as CITY
        ,IFNULL(OPEN_UTC,'{{na}}') as OPEN_UTC
        ,IFNULL(OPEN,'{{na}}') as OPEN
        ,IFNULL(ZONE,'{{na}}') as ZONE
        ,IFNULL(DST_PERIOD,'{{na}}') as DST_PERIOD
        ,IFNULL(CLOSE,'{{na}}') as CLOSE
        ,IFNULL(ID,'{{na}}') as ID
        ,IFNULL(LUNCH_UTC,'{{na}}') as LUNCH_UTC
        ,IFNULL(CLOSE_UTC,'{{na}}') as CLOSE_UTC
        ,IFNULL(NAME,'{{na}}') as NAME
        ,IFNULL(COUNTRY,'{{na}}') as COUNTRY
        ,IFNULL(CAST(DELTA as STRING),'{{na}}') as DELTA
        ,IFNULL(LUNCH,'{{na}}') as LUNCH
        ,LOAD_TS
        ,RECORD_SOURCE
    FROM source_records
),
hashed as(
    SELECT
         src.*
        ,HASH(concat_ws('|',sh.ID)) as EXCHANGE_HKEY
        ,HASH(concat_ws('|',sh.CITY,sh.OPEN_UTC,sh.OPEN,sh.ZONE,sh.DST_PERIOD,sh.CLOSE,sh.LUNCH_UTC,sh.CLOSE_UTC,sh.NAME,
                        sh.COUNTRY,sh.DELTA,sh.LUNCH)) as EXCHANGE_DIFF
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', sh.LOAD_TS) as LOAD_TS_UTC
    FROM source_records src JOIN pre_hash sh ON
            src.ID = sh.ID
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
        ,-1 as EXCHANGE_HKEY  
        ,-1 as EXCHANGE_DIFF   
        ,'1900-01-01' as LOAD_TS_UTC
),
union_records as(
    SELECT * EXCLUDE LOAD_TS FROM hashed
    UNION
    SELECT * EXCLUDE LOAD_TS FROM default_record
)
SELECT *
FROM union_records