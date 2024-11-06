/* get events columns required to indicate product purchase */
WITH events AS (
    SELECT event_id,
           user_id,
           session_id,
           created_at,
           event_type,
           product_id
    FROM {{ ref('stg_postgres_events') }}
),
/* get the session ID for sessions ending in a purchase */
sessions_with_purchase AS ({{ get_purchase_sessions('events') }}),
/* getevents for sessions that did end in (convert to) a purchase */
products_purchase_sessions AS (
    SELECT s.event_id,
           s.user_id,
           s.session_id,
           s.created_at,
           s.event_type,
           s.product_id,
           1 AS is_purchased
    FROM events s
    -- user INNER JOIN to only get sessions ending in a purchase
    INNER JOIN sessions_with_purchase sp USING (session_id)
)
SELECT *
FROM products_purchase_sessions
