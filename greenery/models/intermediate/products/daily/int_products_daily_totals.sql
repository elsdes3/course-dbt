/* get add-to-cart events from sessions in which a product was purchased */
WITH products_ordered AS (
    SELECT product_id,
           created_at
    FROM {{ ref('int_product_purchases_filtered') }}
    -- get add-to-cart events since only products in a cart can be purchased
    WHERE event_type = 'add_to_cart'
),
/* count number of daily orders (purchases) per product */
daily_orders_by_product AS (
    SELECT product_id,
           TO_DATE(created_at) AS created_at_date,
           COUNT(*) AS num_orders
    FROM products_ordered
    GROUP BY ALL
),
/* get page view events from all sessions */
daily_page_views_per_product_session AS (
    SELECT session_id,
           product_id,
           TO_DATE(created_at) AS created_at_date
    FROM {{ ref('stg_postgres_events') }}
    WHERE event_type = 'page_view'
),
/* count number of daily page views and daily sessions per product */
daily_page_views_by AS (
    SELECT product_id,
           created_at_date,
           COUNT(*) AS num_page_views,
           COUNT(DISTINCT(session_id)) AS num_sessions
    FROM daily_page_views_per_product_session
    GROUP BY ALL
),
/* combine daily sums (orders, page views, sessions) per product */
daily_product_totals AS (
    SELECT pv.product_id,
           pv.created_at_date,
           IFNULL(pv.num_page_views, 0) AS num_page_views,
           IFNULL(pv.num_sessions, 0) AS num_sessions,
           IFNULL(dor.num_orders, 0) AS num_orders
    FROM daily_page_views_by pv
    LEFT JOIN daily_orders_by_product dor USING (product_id, created_at_date)
)
SELECT *
FROM daily_product_totals
