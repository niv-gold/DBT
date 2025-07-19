{% macro run_setup_source_A() %}
    {{log('** Setting up the LANDING / EXTERNAL tables, schema, FF and STAGE for source A system  **', true)}}
    {% do run_query(setup_source_A_sql()) %}
{% endmacro %}

/* Render all 3 macros into a one long sql script */
{% macro setup_source_A_sql() -%}
    {{create_source_A_schema_sql()}}
    {{create_source_A__ff_sql()}}
    {{create_source_A__stage_sql()}}
{% endmacro %}

----------------------------------------------------------------
/* DEFINE the objects for landing and external tables */
----------------------------------------------------------------
{% macro get_source_A_db_name() -%}
    {% do return(target.database) %}
{%- endmacro %}

/* Schema name, where the landing table will be created */
{% macro get_source_A_schema_name() -%}
    {% do return( 'Land_source_A' ) %}
{%- endmacro %}

/* Source_A full FF (file format) path */
{% macro get_source_A_ff_name() -%}
    {% do return( get_source_A_db_name() ~'.'~ get_source_A_schema_name() ~'.source_A__FF' ) %}
     {% do log(' ** {}.{}.source_A__FF **'.format(get_source_A_db_name(),get_source_A_schema_name()),true)%} 
{% endmacro -%}

/* Source A fully qualified name of stage */
{% macro get_source_A_stage_name() -%}
    {% do return( get_source_A_db_name() ~'.'~ get_source_A_schema_name() ~'.source_A_STAGE' ) %}
{% endmacro -%}

/* Create the schema that will hold the objects and landing tables */
{% macro create_source_A_schema_sql() -%}
    CREATE SCHEMA IF NOT EXISTS {{ get_source_A_db_name() }}.{{ get_source_A_schema_name() }}
        COMMENT = 'The Landing Schema for Source A data.' ;
    {% do log(' ** {}.{} **'.format(get_source_A_db_name(),get_source_A_schema_name()),true)%}   
{%- endmacro %}

/* Create the file format */
{% macro create_source_A__ff_sql() -%}
    CREATE FILE FORMAT IF NOT EXISTS {{ get_source_A_ff_name() }}
        TYPE = 'csv'
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        ESCAPE = '\\'
        -- ENCODING = 'ISO-8859-1' -- For nordic languages
        ;
{%- endmacro %}

/* Create Stage to access the file in external storage */
{% macro create_source_A__stage_sql() -%}
    CREATE STAGE IF NOT EXISTS {{ get_source_A_stage_name() }}
    STORAGE_INTEGRATION = "FAKE_S3_INTEGRATION"
    URL = 's3://fake-bucket/path/'
    file_format = {{ get_source_A_ff_name() }};
{%- endmacro %}