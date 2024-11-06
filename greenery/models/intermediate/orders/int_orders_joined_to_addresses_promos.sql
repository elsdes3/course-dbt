/* get orders */
WITH orders AS (
    SELECT *
    FROM {{ ref('stg_postgres_orders') }}
),
/* get users */
users AS (
    SELECT user_id,
           address_id
    FROM {{ ref('stg_postgres_users') }}
),
/* get order items */
order_items AS (
    SELECT *
    FROM {{ ref('stg_postgres_order_items') }}
),
/* get promotion discount in dollars */
promos AS (
    SELECT promo_id,
           discount
    FROM {{ ref('stg_postgres_promos') }}
),
/* get state in which user's address is located */
addresses AS (
    SELECT address_id,
           state AS state_name
    FROM {{ ref('stg_postgres_addresses') }}
),
/* get order item summary per order */
order_items_by_order AS (
    SELECT order_id,
        -- get number of unique products per order
        COUNT(DISTINCT(product_id)) as num_unique_products,
        -- get total quantity of products per order
        SUM(quantity) as total_order_size
    FROM order_items
    GROUP BY order_id
),
/* create order profile from combination of orders, order items and promotion
discount */
order_summary AS (
    SELECT oi.order_id,
           o.created_at,
           u.user_id,
           u.address_id,
           o.order_cost,
           o.shipping_cost,
           p.promo_id,
           -- if no discount is offered then the discount value should be zero
           ZEROIFNULL(p.discount) AS discount,
           o.order_total,
           oi.total_order_size,
           oi.num_unique_products,
           o.status,
           o.delivered_at,
           o.estimated_delivery_at
    FROM users u
    LEFT JOIN orders o USING (user_id)
    -- use LEFT JOIN to capture all available users, including those that have
    -- not yet placed orders and so do not yet have any itemized orders
    LEFT JOIN order_items_by_order oi USING (order_id)
    -- use LEFT JOIN to capture orders that do not include products that are
    -- offered as part of a promotion
    LEFT JOIN promos p USING (promo_id)
),
/* append state name to combined order profile */
order_summary_with_state AS (
    SELECT os.order_id,
           os.created_at,
           os.user_id,
           a.state_name,
           os.order_cost,
           os.promo_id,
           os.shipping_cost,
           os.discount,
           os.order_total,
           os.total_order_size,
           os.num_unique_products,
           os.status,
           os.delivered_at,
           os.estimated_delivery_at,
           -- append column to indicate if delivery timestamp occurred later
           -- than estimated delivery timestamp
           (
               CASE
                   WHEN
                       delivered_at > estimated_delivery_at
                       AND status = 'delivered'
                   THEN False
                   WHEN status = 'shipped' THEN NULL
                   ELSE True
               END
           ) AS is_on_time_delivery
    FROM order_summary os
    INNER JOIN addresses a USING (address_id)
)
SELECT *
FROM order_summary_with_state
