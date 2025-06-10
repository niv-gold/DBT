WITH source as(
    SELECT *
    FROM {{ ref("REF_ABC_BANK_COUNTRY_INFO")}}
)
SELECT *
FROM source