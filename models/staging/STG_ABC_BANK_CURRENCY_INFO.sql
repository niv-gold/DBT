{{ config(materialized='ephemeral') }}
{% set na = var('na', '∅') %}

WITH source_records as(
    SELECT
         DECIMALDIGITS as DECIMAL_DIGITS -- NUMBER
        ,CURRENCYNAME as CURRENCY_NAME -- TEXT
        ,NUMERICCODE as NUMERIC_CODE -- NUMBER
        ,LOCATIONS as LOCATIONS -- TEXT
        ,ALPHABETICCODE as ALPHABETIC_CODE -- TEXT

        ,LOAD_TS as LOAD_TS  -- TIMESTAMP_NTZ
        ,'SEEDS.ABC_BANK_CURRENCY_INFO' as RECORD_SOURCE -- TEXT
    FROM {{ source("seeds","ABC_BANK_CURRENCY_INFO")}}
),
pre_hashed as(
    SELECT
         IFNULL(CAST(DECIMAL_DIGITS as STRING),'{{na}}') as DECIMAL_DIGITS
        ,IFNULL(CURRENCY_NAME,'{{na}}') as CURRENCY_NAME
        ,IFNULL(CAST(NUMERIC_CODE as STRING),'{{na}}') as NUMERIC_CODE
        ,IFNULL(LOCATIONS,'{{na}}') as LOCATIONS
        ,IFNULL(CAST(ALPHABETIC_CODE as STRING),'{{na}}') as ALPHABETIC_CODE
        ,LOAD_TS
        ,RECORD_SOURCE

    FROM source_records
),
hashed as(
    SELECT
        src.*
        ,HASH(concat_ws('|',hs.NUMERIC_CODE,hs.ALPHABETIC_CODE)) as CURRENCY_HKEY
        ,HASH(concat_ws('|',hs.DECIMAL_DIGITS,hs.CURRENCY_NAME,hs.NUMERIC_CODE,hs.LOCATIONS,hs.ALPHABETIC_CODE))
            as CURRENCY_HDIFF
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', hs.LOAD_TS) as LOAD_TS_UTC  
    FROM source_records src JOIN  pre_hashed hs ON 
        src.NUMERIC_CODE = hs.NUMERIC_CODE
        AND src.ALPHABETIC_CODE = hs.ALPHABETIC_CODE
),
default_record as(
        SELECT
         -1 as DECIMAL_DIGITS -- NUMBER
        ,'Missing' as CURRENCY_NAME -- TEXT
        ,-1 as NUMERIC_CODE -- NUMBER
        ,'Missing' as LOCATIONS -- TEXT
        ,'Missing' as ALPHABETIC_CODE -- TEXT
        ,'1900-01-01' as LOAD_TS  -- TIMESTAMP_NTZ
        ,'Missing' as RECORD_SOURCE -- TEXT
        ,-1 as CURRENCY_HKEY
        ,-1 as CURRENCY_HDIFF
        ,'1900-01-01' as LOAD_TS_UTC
),
union_records as(
    SELECT * EXCLUDE LOAD_TS FROM hashed
    UNION
    SELECT * EXCLUDE LOAD_TS FROM default_record
)
SELECT *
FROM union_records