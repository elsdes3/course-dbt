WITH order_summary AS (
    SELECT order_id,
           created_at,
           state_name,
           order_cost,
           promo_id,
           discount,
           order_total,
           total_order_size,
           num_unique_products,
           estimated_delivery_at,
           delivered_at,
           status
    FROM {{ ref('int_orders_joined_to_addresses_promos') }}
),
orders_with_delivery_details AS (
    SELECT *,
           datediff(
               second, created_at, estimated_delivery_at
           ) AS estimated_delivery_time_seconds,
           datediff(second, created_at, delivered_at) AS delivery_time_seconds,
           (
               CASE
                   WHEN delivered_at > estimated_delivery_at
                   THEN ABS(
                       DATEDIFF(second, delivered_at, estimated_delivery_at)
                   )
                   ELSE NULL
               END
           ) AS delivery_delay_seconds
    FROM order_summary
)
SELECT *
FROM orders_with_delivery_details
