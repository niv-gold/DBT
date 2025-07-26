{% macro return_str() -%} 
    {{return ('Hello World')}}
{%- endmacro %}

{% macro get_today() -%}
     CURRENT_DATE
{%- endmacro %}

{% macro get_today_utc() -%}
    {{ return(datetime.utcnow().strftime('%Y-%m-%d')) }}
{%- endmacro %}