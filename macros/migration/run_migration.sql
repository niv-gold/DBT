{% macro run_migration(database, schema_prefix) -%}
    {% set database = database or target.database %}
    {% set schema_prefix = schema_prefix or target.schema %}
    
    {% if execute %}
        {% do V0001_drop_example_table(database,schema_prefix) %}
        {% do run_query(V002_DROP_REF_POSITION_ABC_BANK()) %}
        {% do V003_drop_table_with_old_name(database,schema_prefix) %}
    {% endif %}
{%- endmacro %}
