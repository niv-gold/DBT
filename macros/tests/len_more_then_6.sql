{% test len_more_then_6(model, column_name) -%}
WITH validation_errors as(
    SELECT {{column_name}}
    FROM {{model}}
    WHERE LENGTH({{column_name}})> 10000000
)
SELECT * FROM validation_errors
{%- endtest %}