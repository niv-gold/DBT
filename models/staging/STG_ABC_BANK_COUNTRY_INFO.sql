{{ config(materialized='ephemeral') }}
{% set na = var('na', '∅') %}


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
pre_hashed as(
    SELECT  
         IFNULL(COUNTRY_NAME,'{{na}}') as COUNTRY_NAME
        ,IFNULL(COUNTRY_CODE_2_LETTER,'{{na}}') as COUNTRY_CODE_2_LETTER
        ,IFNULL(COUNTRY_CODE_3_LETTER,'{{na}}') as COUNTRY_CODE_3_LETTER
        ,IFNULL(CAST(COUNTRY_CODE_NUMERIC as STRING),'{{na}}') as COUNTRY_CODE_NUMERIC
        ,IFNULL(ISO_3166_2,'{{na}}') as ISO_3166_2
        ,IFNULL(REGION,'{{na}}') as REGION
        ,IFNULL(SUB_REGION,'{{na}}') as SUB_REGION
        ,IFNULL(INTERMEDIATE_REGION,'{{na}}') as INTERMEDIATE_REGION
        ,IFNULL(CAST(REGION_CODE as STRING),'{{na}}') as REGION_CODE
        ,IFNULL(CAST(SUB_REGION_CODE as STRING),'{{na}}') as SUB_REGION_CODE
        ,IFNULL(CAST(INTERMEDIATE_REGION_CODE as STRING),'{{na}}') as INTERMEDIATE_REGION_CODE
        ,LOAD_TS
        ,RECORD_SOURCE
    FROM src_data
),
hashed as(
    SELECT 
         src.*
        ,HASH(concat_ws('|', hs.COUNTRY_CODE_3_LETTER)) as COUNTRY_HKEY
        ,HASH(concat_ws('|', hs.COUNTRY_NAME,hs.COUNTRY_CODE_2_LETTER,hs.COUNTRY_CODE_3_LETTER,hs.COUNTRY_CODE_NUMERIC,
         hs.REGION,hs.SUB_REGION,hs.INTERMEDIATE_REGION,hs.REGION_CODE,hs.SUB_REGION_CODE,hs.INTERMEDIATE_REGION_CODE)) 
         as COUNTRY_HDIFF        
        ,CONVERT_TIMEZONE('UTC', 'Asia/Jerusalem', hs.LOAD_TS) as LOAD_TS_UTC        
    FROM src_data src JOIN pre_hashed hs ON 
            src.COUNTRY_NAME = hs.COUNTRY_NAME
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
        ,-1 as COUNTRY_HKEY                     -- NUMBER
        ,-1 as COUNTRY_HDIFF                    -- NUMBER
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