WITH orders_with_delivery_time AS (
    SELECT user_id,
           state_name,
           created_at,
           discount,
           order_total,
           num_unique_products,
           total_order_size,
           status,
           order_id,
           datediff(second, created_at, delivered_at) AS delivery_time_seconds
    FROM {{ ref('int_orders_joined_to_addresses_promos') }}
),
user_order_summary AS (
    SELECT user_id,
           state_name,
           TO_DATE(MIN(created_at)) AS first_order_date,
           TO_DATE(MAX(created_at)) AS last_order_date,
           ZEROIFNULL(SUM(discount)) AS discount_value,
           -- get total dollar value of all orders by user, rounded to three
           -- decimal places
           ZEROIFNULL(ROUND(SUM(order_total), 2)) AS order_value,
           -- get average number of products in an order
           ZEROIFNULL(
               ROUND(AVG(num_unique_products))
           ) AS avg_num_unique_products,
           -- get average order size
           ZEROIFNULL(ROUND(AVG(total_order_size))) as avg_order_size,
           -- get total number of orders by user
           ZEROIFNULL(COUNT(order_id)) AS num_orders,
           -- get total number of delivered orders by user
           SUM(
               CASE WHEN status = 'delivered' THEN 1 ELSE 0 END
           ) AS num_orders_delivered,
           -- get total number of orders by user that are shipping
           SUM(
               CASE WHEN status = 'shipped' THEN 1 ELSE 0 END
           ) AS num_orders_shipping,
           -- get average delivery time for delivered orders by user
           ROUND(AVG(delivery_time_seconds)) AS avg_delivery_time_seconds
    FROM orders_with_delivery_time
    GROUP BY ALL
    ORDER BY order_value DESC
)
SELECT *
FROM user_order_summary
