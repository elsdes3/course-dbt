{%- macro count_add_to_carts_by_product(event_type, cte_name, group_by_col_name) -%}

{%- if 'non' not in cte_name %}
    {%- set outcome='purchase' %}
{%- elif 'non' in cte_name %}
    {%- set outcome='non_purchase' %}
{%- endif %}

{%- set outcome_col_name="num_{}_{}s".format(outcome,event_type) -%}

SELECT {{ group_by_col_name }},
       COUNT(*) AS {{ outcome_col_name }}
FROM {{ cte_name }}
-- get add-to-cart events in product {{ outcome.replace('_', '-') }} sessions
WHERE event_type = '{{ event_type }}'
GROUP BY {{ group_by_col_name }}

{%- endmacro -%}
