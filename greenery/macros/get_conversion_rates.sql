{% macro get_conversion_rates(agg_type) -%}
        WITH products AS (
            {% if agg_type == 'product' -%}
            SELECT product_id,
                   name AS product_name
            FROM {{ ref('stg_postgres_products') }}
            {%- else -%}
            SELECT 1 AS product_id,
                   'all' AS product_name
            {%- endif %}
        ),
        /* get conversion rate */
        {{ agg_type }}_conversion_rates AS (
            SELECT {% if agg_type == 'product' -%}
                   product_id,
                   (
                       num_non_purchase_page_view_sessions
                       +num_purchase_page_view_sessions
                   ) AS total_num_page_view_sessions,
                   num_purchases AS num_purchase_sessions,
                   {% else -%}
                   1 AS product_id,
                   SUM(
                       num_non_purchase_page_view_sessions
                       +num_purchase_page_view_sessions
                   ) AS total_num_page_view_sessions,
                   SUM(num_purchases) AS num_purchase_sessions,
                   {% endif -%}
                   (
                       100*num_purchase_sessions/total_num_page_view_sessions
                   ) AS conversion_rate
            FROM {{ ref('int_events_sessions_aggregated_to_product') }}
        ),
        /* get first and last event timestamp */
        event_timestamp_bounds AS (
            SELECT {% if agg_type == 'product' %}
                   product_id,
                   {% else -%}
                   1 AS product_id,
                   {% endif -%}
                   MIN(created_at) AS first_event,
                   MAX(created_at) AS last_event
            FROM {{ ref('stg_postgres_events') }}
            {% if agg_type == 'product' -%}
            GROUP BY product_id
            {%- else %}
            {%- endif %}
        ),
        /* combine conversion rates and event timestamp bounds */
        conversion_rates_timestamp_bounds AS (
            SELECT p.product_name,
                   c.total_num_page_view_sessions,
                   c.num_purchase_sessions,
                   c.conversion_rate,
                   b.first_event,
                   b.last_event
            FROM {{ agg_type }}_conversion_rates c
            INNER JOIN event_timestamp_bounds b USING (product_id)
            INNER JOIN products p USING (product_id)
            ORDER BY conversion_rate DESC
        )
        SELECT *
        FROM conversion_rates_timestamp_bounds
{%- endmacro %}
