WITH source as(
    SELECT *
    FROM {{ ref('REF_ABC_BANK_CURRENCY_INFO') }}
)
SELECT *
FROM source 