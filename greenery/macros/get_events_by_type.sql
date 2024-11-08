{%- macro get_events_by_type(events_cte) -%}
    SELECT {% if events_cte == 'int_product_purchases_filtered' -%}
           {{ get_standard_events_columns() }},
           is_purchased
           {%- else -%}
           {{ get_standard_events_columns() }}
           {%- endif %}
    FROM {{ events_cte }}
{%- endmacro %}
