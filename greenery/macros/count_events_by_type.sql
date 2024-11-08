{%- macro count_events_by_type(events_cte, event_name) -%}
    SELECT session_id,
           user_id,
           product_id,
           created_at_date,
           {% if (event_name == 'page_view') or ((event_name == 'add_to_cart') and (events_cte == 'non_events')) -%}
           COUNT(*) AS num_{{ event_name }}s
           {%- else -%}
           1 AS num_{{ event_name }}s,
           MAX(is_purchased) AS num_checkouts
           {%- endif %}
    FROM {{ events_cte }}
    WHERE event_type = '{{ event_name }}'
    GROUP BY ALL
{%- endmacro %}
