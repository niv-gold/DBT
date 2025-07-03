{% macro V0001_drop_example_table(
    database = target.database,
    schema_prefix = target.schema
) -%}
    {% set sql %}
        DROP TABLE IF EXISTS {{database}}.{{schema_prefix}}_REFINED.TABLE_XXX ;
    {% endset %}
    
    {% do log("About to run: " ~ sql, info=True) %}
    {% do run_query(sql) %}
{%- endmacro %}
