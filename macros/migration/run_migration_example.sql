{% macro run_migration_example(database, schema_prefix) -%}
    {% set database = database or target.database %}
    {% set schema_prefix = schema_prefix or target.schema %}
    
    {# do - is a function that execute functions within the macro, used for functions with only side effect #}
    {# log - a side effect only function that print to the dbt script log/output #}
    {% do log( "### -- 1 -- Running V001_drop_example_table migration with database = " ~ database ~ ", schema = " ~ schema_prefix, info=True) %}

    {# do - create a side effect by executing a DDL SQL script. nested run_query() #}
    {% do V0001_drop_example_table(database, schema_prefix) %}

    {# set + do + run_query #}
    {% set drop_sql = drop_REF_POSITION_ABC_BANK() %}
    {% do log("About to run: " ~ drop_sql, info=True) %}
    {% do run_query(drop_sql) %}

    {# do + run_query #}
    {% do run_query(drop_REF_POSITION_ABC_BANK())%}

    {# Uncomment this if no migration to run #}
    {# {% do log("No migration to run.", info=True) %} #}
{%- endmacro %}
