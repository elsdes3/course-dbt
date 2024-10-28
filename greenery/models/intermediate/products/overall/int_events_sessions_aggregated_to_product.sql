/* get events for sessions that did not end in a purchase */
WITH products_non_purchase_sessions AS (
    SELECT session_id,
           product_id,
           event_type
    FROM {{ ref('int_product_non_purchases_filtered') }}
),
/* get events for sessions that did end in (convert to) a purchase */
products_purchase_sessions AS (
    SELECT session_id,
           product_id,
           event_type
    FROM {{ ref('int_product_purchases_filtered') }}
),
/* count number of sessions not ending in a purchase in which product page was
viewed */
product_non_purchase_page_views AS (
    SELECT product_id,
           COUNT(*) AS num_non_purchase_page_views,
           COUNT(DISTINCT(session_id)) AS num_non_purchase_page_view_sessions
    FROM products_non_purchase_sessions
    -- get the page view event from sessions in which product was not ordered
    WHERE event_type = 'page_view'
    GROUP BY product_id
),
/* count number of sessions ending in a purchase in which product page was
viewed */
product_purchase_page_views AS (
    SELECT product_id,
           COUNT(*) AS num_purchase_page_views,
           COUNT(DISTINCT(session_id)) AS num_purchase_page_view_sessions
    FROM products_purchase_sessions
    -- get the page view event from sessions in which product was ordered
    WHERE event_type = 'page_view'
    GROUP BY product_id
),
/* count purchases */
product_purchases AS (
    SELECT product_id,
           COUNT(DISTINCT(session_id)) AS num_purchases
    FROM products_purchase_sessions
    -- get add-to-cart events since only products in a cart can be purchased
    WHERE event_type = 'add_to_cart'
    GROUP BY product_id
),
/* join the three types of session counts per product */
product_session_totals AS (
    SELECT pp.product_id,
           -- count of sessions with page view but not ending in product
           -- purchase
           npv.num_non_purchase_page_view_sessions,
           -- count of sessions with page view and ending in product purchase
           ppv.num_purchase_page_view_sessions,
           -- count of product purchases
           pp.num_purchases,
           -- count of total page views
           (
               npv.num_non_purchase_page_views
               + ppv.num_purchase_page_views
           ) AS num_page_views
    FROM product_non_purchase_page_views npv
    INNER JOIN product_purchases pp USING (product_id)
    INNER JOIN product_purchase_page_views ppv USING (product_id)
)
SELECT *
FROM product_session_totals
