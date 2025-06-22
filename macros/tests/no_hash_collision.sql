{% test no_hash_collision(model, column_name, hashed_fields) -%}
{{ config(severity='warn')}}
    with
        all_tuples as (
            select distinct {{ column_name }} as hash, {{ hashed_fields }}
            from {{ model }}
        ),
        validation_errors as (
            select hash, count(*) as cnt
            from all_tuples
            group by hash
            having count(*) > 1
        )
    select *
    from validation_errors
{%- endtest %}

{% macro as_sql_list(columns) -%}
  {{ columns | join(', ') }}
{%- endmacro %}
