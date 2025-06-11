WITH source as(
    SELECT *
    FROM {{ ref('REF_ABC_BANK_EXCHANGE_INFO') }}
)
SELECT *
FROM source