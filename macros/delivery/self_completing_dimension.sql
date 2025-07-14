{% macro self_completing_dimension(
    dim_rel,
    dim_key_column,
    dim_default_key_value = '-1',
    rel_column_to_exclude = [],
    fact_defs = [] 
) -%}
    {% do rel_column_to_exclude.append(dim_key_column) -%}

    with
    dim_base as(
        SELECT
            {{dim_key_column}}
            ,d.* EXCLUDE( {{rel_column_to_exclude|join(', ')}} )
        FROM {{ dim_rel }} as d
    ),
    fact_key_list as( --gether dim PK's from all facts (using a for loop on a list of dict's with fact details)
        {% if fact_defs|length > 0 %} --if some FACT passed
            {%- for fact_model_key in fact_defs %}
                SELECT DISTINCT
                    {{fact_model_key['key']}}  as FOREIGN_KEY
                FROM {{fact_model_key['model']}}
                WHERE {{fact_model_key['key']}} is not null
                    {% if not loop.last %} union {% endif %}
            {% endfor %}
        {%- else %} --If no fact, list is empty
            SELECT null as FOREIGN_KEY 
            WHERE false
        {% endif %}
    ),
    missing_keys as(
        SELECT 
            fk1.FOREIGN_KEY
        FROM fact_key_list fk1 LEFT JOIN dim_base ON
            dim_base.{{dim_key_column}} = fk1.FOREIGN_KEY
        WHERE dim_base.{{dim_key_column}} is null
    ),
    default_record as(
        SELECT *
        FROM dim_base
        WHERE {{dim_key_column}} = '{{dim_default_key_value}}'
        LIMIT 1
    ),
    dim_missing_entries as(
        SELECT
            mk.FOREIGN_KEY,
            dr.* EXCLUDE({{dim_key_column}})
        FROM missing_keys mk JOIN default_record dr  --Cross join as no ON clause was defined.
    ),
    dim as(
        SELECT *
        FROM dim_base
        UNION all
        SELECT * FROM dim_missing_entries
    )
    SELECT * FROM dim
{% endmacro %}