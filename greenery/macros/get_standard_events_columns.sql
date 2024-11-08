{%- macro get_standard_events_columns() -%}
           session_id,
           user_id,
           TO_DATE(created_at) AS created_at_date,
           created_at,
           event_type,
           product_id
{%- endmacro %}
