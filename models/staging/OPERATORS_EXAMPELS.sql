{{ config(enabled=false) }}

--Litteral calaculations
SELECT {{1 + 1}} -- print 2

-- Booleans
SELECT {{4==1}} --1
SELECT {{1 in [2,3,4]}} --2
SELECT {{1 in [2,3,4,1]}} --3
SELECT {{'ab' in ['vf','er','ab']}} --4
SELECT {{ 70 > 5}} --5

--Return a srting litteral
SELECT '{{ return_str() }}' as greeting
{% set name = 'Niv' %}
-- Operators:
-- passing a variable using () 
SELECT {{"Welcome {}!".format(name)}}
-- concatination
SELECT {{1 ~ " pluse " ~ 2}}{{' equal '}}{{1+2}}
--is using variables
{% set var1 = 3 %}
SELECT {{(var1) is integer}} --1
SELECT {{(var1) is boolean}} --2
SELECT {{(var1) is defined}} --3
SELECT {{(var1) is undefined}} --4
{% set var2 = none %}
SELECT {{var2 is none}} --5  --Python dosn't use null, it use none!!!
SELECT {{var1 is even}} --6
SELECT {{var1 is odd}} --7
SELECT {{'ABC' is lower}} --8
SELECT {{'aBc' is lower}} --9
SELECT {{'abc' is lower}} --10
SELECT {{'ABC' is upper}} --11

--Pipe operator
SELECT '{{"show_me_the_money" | upper}}'
SELECT {{("show_me_the_money" | upper | lower) is integer}}
SELECT {{"show_me_the_money" | upper | length}}

-- Define dictionary and acces it's attributes
{% set dict_1 = {
    "US" : "United States",
    "IL" : "Israel",
    "DE" : "Germany"
} %}
{% for key, value in dict_1.items() -%}
    {{ key }}, {{ value }} {% if not loop.last %},{% endif %}
{%- endfor %}

-- using a mutable var inside a for loop with spacename object to append values into list:
{% set ns = namespace(lst_a=[]) %}
{% for key, value in dict_1.items() -%}
    {% do ns.lst_a.append(value) %}
{%- endfor %}
{{ns.lst_a}} 

-- using a mutable var inside a for loop with spacename object to sume values into list:
{% set ns = namespace(lst_a=[]) %}
{% for key, value in dict_1.items() -%}
    {% do ns.lst_a.append(value) %}
{%- endfor %}
{{ns.lst_a}} 

SELECT '{{dict_1['IL'] | upper}}' as country_name
SELECT '{{dict_1.IL | lower}}' as country_name

{% for item in dict_1 -%}
   {{dict_1[item]}} {% if not loop.last %},{% endif %}
{%- endfor %}

-- List
{% set lst_1 = ['a','b','c'] %}
SELECT '{{lst_1[0]}}' -- first object
SELECT '{{lst_1[-1]}}' -- last object
SELECT '{{lst_1[::-1]}}'  --reverce order

-- IF statement
{% set var3 = 21 %}
{% if var3%5 == 0 %}
    SELECT {{'{} devided by 5'.format(var3)}}
    SELECT {{var3%5 }} {{var3//5}} -- // print the diviation calc as an integer.
{% else %}
    SELECT {{"{} isnt divided by 5".format(var3)}}
    SELECT {{var3%5 }} {{var3//5}}
{% endif %}

-- SET variables
{% set var_a, var_b, var_c = 1, 2, 3 %}
SELECT {{var_a}}, {{var_b}}, {{var_c}}

-- set a daynamicly pice of code
{% set start_date, end_date = '2021-01-01', '2025-12-31' %}
{% set date_filter %}
DATE between '{{start_date}}' and '{{end_date}}'
{% endset %}
{{date_filter}}


{{as_sql_list(['ACCOUNT_CODE', 'SECURITY_CODE', 'SECURITY_NAME', 'EXCHANGE_CODE', 'REPORT_DATE', 'QUANTITY', 'COST_BASE', 'POSITION_VALUE', 'CURRENCY_CODE'])}}

DROP TABLE IF EXISTS {{target.database}}.{{target.schema}}_REFINED.REF_ABC_BANK_SECURITY_INFO;