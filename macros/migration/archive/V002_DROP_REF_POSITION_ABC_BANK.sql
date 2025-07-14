{% macro V002_DROP_REF_POSITION_ABC_BANK() %}
    DROP TABLE IF EXISTS {{target.database}}.{{target.schema}}_REFINED.REF_POSITION_ABC_BANK;
{% endmacro %}