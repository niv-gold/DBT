{% macro V003_drop_table_with_old_name(
            database = target.database,
            schema_prefix = target.schema
) -%}
    {% set sql %}
        DROP TABLE IF EXISTS {{database}}.{{schema_prefix}}_REFINED.REF_ABC_BANK_SECURITY_INFO;
    {% endset %}

    {% do log("About to run: " ~ sql, info=True) %}
    {% do run_query(sql) %}
{%- endmacro %}