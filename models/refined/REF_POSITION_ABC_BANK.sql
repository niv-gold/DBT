WITH 
position as(
    {{ current_from_history(
        history_rel = ref('HIST_ABC_BANK_POSITION_WITH_CLOSING'),
        key_column = 'POSITION_HKEY',
    ) }}
),
security as(
    SELECT * FROM {{ ref('REF_SECURITY_INFO_ABC_BANK') }}
)
SELECT
    p.*
    ,POSITION_VALUE - COST_BASE as UNREALIZED_PROFIT
    ,ROUND(DIV0(UNREALIZED_PROFIT,COST_BASE),5)*100 as UNREALIZED_PROFIT_PCT
FROM position p