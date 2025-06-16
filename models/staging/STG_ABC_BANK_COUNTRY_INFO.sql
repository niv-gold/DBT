{{ config(materialized='ephemeral') }}

WITH src_data as (
     SELECT 
         COUNTRY_NAME as COUNTRY_NAME                            -- TEXT
        ,COUNTRY_CODE_2_LETTER as COUNTRY_CODE_2_LETTER         -- TEXT
        ,COUNTRY_CODE_3_LETTER as COUNTRY_CODE_3_LETTER         -- TEXT
        ,COUNTRY_CODE_NUMERIC as COUNTRY_CODE_NUMERIC           -- NUMBER
        ,ISO_3166_2 as ISO_3166_2                               -- TEXT
        ,REGION as REGION                                       -- TEXT
        ,SUB_REGION as SUB_REGION                               -- TEXT
        ,INTERMEDIATE_REGION as INTERMEDIATE_REGION             -- TEXT
        ,REGION_CODE as REGION_CODE                             -- NUMBER
        ,SUB_REGION_CODE as SUB_REGION_CODE                     -- NUMBER
        ,INTERMEDIATE_REGION_CODE as INTERMEDIATE_REGION_CODE   -- NUMBER
        ,LOAD_TS as LOAD_TS                                     -- TIMESTAMP_NTZ

        ,'SEEDS.ABC_BANK_COUNTRY_INFO' as RECORD_SOURCE          -- TEXT        
    FROM {{ source('seeds','ABC_BANK_COUNTRY_INFO')}}
),
hashed as(
    SELECT 
         *
        ,{{dbt_utils.surrogate_key(['COUNTRY_CODE_3_LETTER'])}} AS COUNTRY_HKEY
        ,{{dbt_utils.surrogate_key(['COUNTRY_NAME','COUNTRY_CODE_2_LETTER','COUNTRY_CODE_3_LETTER','COUNTRY_CODE_NUMERIC','REGION', 'SUB_REGION','INTERMEDIATE_REGION','REGION_CODE','SUB_REGION_CODE','INTERMEDIATE_REGION_CODE'])}} 
         as COUNTRY_HDIFF
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', LOAD_TS) as LOAD_TS_UTC        
    FROM src_data
),
default_record as(
    SELECT 
         'Missing' as COUNTRY_NAME              -- TEXT
        ,'Missing' as COUNTRY_CODE_2_LETTER     -- TEXT
        ,'Missing' as COUNTRY_CODE_3_LETTER     -- TEXT
        ,-1 as COUNTRY_CODE_NUMERIC             -- NUMBER
        ,'Missing' as ISO_3166_2                -- TEXT
        ,'Missing' as REGION                    -- TEXT
        ,'Missing' as SUB_REGION                -- TEXT
        ,'Missing' as INTERMEDIATE_REGION       -- TEXT
        ,-1 as REGION_CODE                      -- NUMBER
        ,-1 as SUB_REGION_CODE                  -- NUMBER
        ,-1 as INTERMEDIATE_REGION_CODE         -- NUMBER
        ,'1900-01-01' as LOAD_TS                -- TIMESTAMP_NTZ
        ,'Missing' as RECORD_SOURCE             -- TEXT
        ,'-1' as COUNTRY_HKEY                     -- NUMBER
        ,'-1' as COUNTRY_HDIFF                    -- NUMBER
        ,'1900-01-01' as LOAD_TS_UTC            -- TIMESTAMP_NTZ
),
union_records as(
    SELECT * EXCLUDE LOAD_TS
    FROM hashed
    UNION
    SELECT * EXCLUDE LOAD_TS
    FROM default_record      
)
SELECT *
FROM union_records