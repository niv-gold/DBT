SELECT *
FROM {{ ref('STG_ABC_BANK_SECURITY_INFO')}}
WHERE SECURITY_CODE = '-1'
    AND RECORD_SOURCE != 'Missing'