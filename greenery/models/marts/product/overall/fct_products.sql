/* get average time spent viewing product page */
WITH product_page_timings AS (
    SELECT *
    FROM {{ ref('int_products_page_viewing_time_averaged') }}
),
/* get number of times product was added to cart */
product_carts AS (
    SELECT product_id,
           num_carts
    FROM {{ ref('int_products_purchase_abandoned_cart_sessions_summed') }}
),
/* get total product page views (traffic) and purchases */
product_traffic_purchases AS (
    SELECT product_id,
           num_purchases,
           num_page_views,
           -- calculate total number of sessions (with or without a purchase)
           -- in which a product page was viewed
           {{ add_columns(
               'num_non_purchase_page_view_sessions',
               'num_purchase_page_view_sessions',
               'num_page_view_sessions'
           ) }}
    FROM {{ ref('int_events_sessions_aggregated_to_product') }}
),
/* combine product metrics and add ranks by page views and purchases */
product_summary AS (
    SELECT pn.name AS product_name,
           pt.num_page_view_sessions,
           pt.num_page_views,
           pt.num_purchases,
           -- rank products by traffic (page views)
           RANK() OVER(ORDER BY num_page_views DESC) AS rank_traffic,
           -- rank products by purchases
           RANK() OVER(ORDER BY num_purchases DESC) AS rank_purchases,
           -- count total number of products with metrics
           COUNT(*) OVER() AS num_products,
           -- calculate cart abandonment rate
           -- car.cart_abandonment_rate,
           1-(pt.num_purchases/pc.num_carts) AS cart_abandonment_rate,
           -- get average time on product page
           pv.avg_time_on_page_seconds
    FROM product_carts pc
    INNER JOIN product_page_timings pv USING (product_id)
    -- INNER JOIN product_cart_abandonment_rates car USING (product_id)
    INNER JOIN product_traffic_purchases pt USING (product_id)
    -- join to get product name instead of product ID
    INNER JOIN stg_postgres_products pn USING (product_id)
),
/* add product indicators for high traffic (page views) and low conversions
(purchases) */
product_performance_indicators AS (
    SELECT * EXCLUDE(num_products),
           -- add high-traffic indicator per product
           {{ case_when(
               'rank_traffic <= 10', True, False, 'is_high_traffic'
           ) }},
           -- add low-conversion indicator per product
           {{ case_when(
               'rank_purchases >= num_products-10',
               True,
               False,
               'is_low_conversions'
           ) }}
    FROM product_summary
)
SELECT *
FROM product_performance_indicators
