WITH int_product_purchases_filtered AS (
    SELECT *
    FROM {{ ref('int_product_purchases_filtered') }}
),
int_product_non_purchases_filtered AS (
    SELECT *
    FROM {{ ref('int_product_non_purchases_filtered') }}
),
events AS (
    {{ get_events_by_type('int_product_purchases_filtered') }}
),
non_events AS (
    {{ get_events_by_type('int_product_non_purchases_filtered') }}
),
non_purchase_sessions_page_view_counts AS (
    {{ count_events_by_type('non_events', 'page_view') }}
),
non_purchase_sessions_add_to_cart_counts AS (
    {{ count_events_by_type('non_events', 'add_to_cart') }}
),
purchase_sessions_cart_checkout_counts AS (
    {{ count_events_by_type('events', 'add_to_cart') }}
),
purchase_sessions_page_view_counts AS (
    {{ count_events_by_type('events', 'page_view') }}
),
daily_user_sessions AS (
    SELECT session_id,
           user_id,
           product_id,
           created_at_date,
           num_page_views,
           num_add_to_carts,
           num_checkouts
    FROM purchase_sessions_page_view_counts
    LEFT JOIN purchase_sessions_cart_checkout_counts
        USING (session_id, user_id, product_id, created_at_date)
    UNION ALL
    SELECT session_id,
           user_id,
           product_id,
           created_at_date,
           num_page_views,
           num_add_to_carts,
           0 AS num_checkouts
    FROM non_purchase_sessions_page_view_counts
    LEFT JOIN non_purchase_sessions_add_to_cart_counts
        USING (session_id, user_id, product_id, created_at_date)
),
bounce_sessions AS (
    SELECT session_id,
           user_id,
           created_at_date,
           1 AS is_bounce_session
    FROM daily_user_sessions
    GROUP BY ALL
    HAVING SUM(num_page_views) = 1
    AND SUM(num_add_to_carts) = 0
    AND SUM(num_checkouts) = 0
),
daily_user_sessions_no_nulls AS (
    SELECT session_id,
           user_id,
           product_id,
           created_at_date,
           ZEROIFNULL(num_page_views) AS num_page_views,
           ZEROIFNULL(num_add_to_carts) AS num_add_to_carts,
           ZEROIFNULL(num_checkouts) AS num_checkouts,
           ZEROIFNULL(is_bounce_session) AS is_bounce_session
    FROM daily_user_sessions
    LEFT JOIN bounce_sessions USING (session_id, user_id, created_at_date)
)
SELECT *
FROM daily_user_sessions_no_nulls
