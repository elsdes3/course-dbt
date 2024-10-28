WITH order_summary AS (
    SELECT order_id,
           TO_DATE(created_at) AS created_at_date,
           order_cost,
           promo_id,
           discount,
           shipping_cost,
           total_order_size,
           num_unique_products
    FROM {{ ref('int_orders_joined_to_addresses_promos') }}
),
promo_order_summary AS (
    SELECT promo_id,
           created_at_date,
           COUNT(*) AS num_orders,
           SUM(discount) AS promo_discount,
           ROUND(SUM(shipping_cost), 2) AS shipping_cost,
           SUM(order_cost) AS order_cost,
           ROUND(AVG(num_unique_products)) AS avg_num_unique_products,
           ROUND(AVG(total_order_size)) AS avg_total_order_size
    FROM order_summary
    WHERE promo_id IS NOT NULL
    GROUP BY promo_id, created_at_date
    ORDER BY created_at_date ASC, promo_discount DESC
)
SELECT *
FROM promo_order_summary
