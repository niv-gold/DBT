{{ config(materialized='view') }}

WITH source as(
    SELECT *
    FROM {{ref('HIST_ABC_BANK_POSITION')}}
    WHERE NOT CLOSED
)
SELECT *
FROM source