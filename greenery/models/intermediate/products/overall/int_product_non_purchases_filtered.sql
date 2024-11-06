/* get events for sessions that did not end in a purchase */
WITH products_non_purchase_sessions AS (
    SELECT event_id,
           user_id,
           session_id,
           created_at,
           event_type,
           product_id,
           0 AS is_purchased
    FROM {{ ref('stg_postgres_events') }}
    -- get sessions in which the last event does not indicate a purchase
    {{ filter_sessions_by_last_event(('page_view', 'add_to_cart')) }}
)
SELECT *
FROM products_non_purchase_sessions
