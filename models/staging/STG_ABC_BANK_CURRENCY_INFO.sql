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
hashed as(
    SELECT
        *
        ,{{dbt_utils.surrogate_key(['NUMERIC_CODE','ALPHABETIC_CODE'])}} as CURRENCY_HKEY
        ,{{dbt_utils.surrogate_key(['DECIMAL_DIGITS','CURRENCY_NAME','NUMERIC_CODE','LOCATIONS','ALPHABETIC_CODE'])}} 
         as CURRENCY_HDIFF
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', LOAD_TS) as LOAD_TS_UTC  
    FROM source_records
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
        ,'-1' as CURRENCY_HKEY
        ,'-1' as CURRENCY_HDIFF
        ,'1900-01-01' as LOAD_TS_UTC
),
union_records as(
    SELECT * EXCLUDE LOAD_TS FROM hashed
    UNION
    SELECT * EXCLUDE LOAD_TS FROM default_record
)
SELECT *
FROM union_records