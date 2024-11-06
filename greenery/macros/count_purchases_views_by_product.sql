{% macro count_purchases_views_by_product(event_type, cte_name, group_by_col_name) %}

{%- if event_type == 'add_to_cart' -%}
    SELECT {{ group_by_col_name }},
           COUNT(DISTINCT(session_id)) AS num_purchases
    FROM {{ cte_name }}
    -- get add-to-cart events since only products in a cart can be purchased
    WHERE event_type = '{{ event_type }}'
    GROUP BY {{ group_by_col_name }}

{%- elif event_type == 'page_view' %}
{%- if 'non' not in cte_name %}
    {%- set outcome='purchase' %}
{%- elif 'non' in cte_name %}
    {%- set outcome='non_purchase' %}
{%- endif -%}

{%- set session_col_name="num_{}_{}_sessions".format(outcome,event_type) -%}
{%- set outcome_col_name="num_{}_{}s".format(outcome,event_type) -%}

    SELECT {{ group_by_col_name }},
           COUNT(*) AS {{ outcome_col_name }},
           COUNT(DISTINCT(session_id)) AS {{ session_col_name }}
    FROM {{ cte_name }}
    -- get page view event in product {{ outcome.replace('_', '-') }} sessions
    WHERE event_type = '{{ event_type }}'
    GROUP BY {{ group_by_col_name }}

{%- endif -%}

{% endmacro %}
