{% macro to_21st_century_date(date_culomn_name) -%}
    CASE 
        WHEN {{date_culomn_name}} >= '0100-01-01'::date
        THEN {{date_culomn_name}}
        ELSE DATEADD(year,2000,{{date_culomn_name}})
    END
{%- endmacro %}