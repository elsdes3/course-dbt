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
    -- (ADDED) get events showing the ID of the purchased product
    WHERE product_id IS NOT NULL
),
/* count number of times product was added to a cart in sessions not ending
in a purchase */
product_non_purchase_add_to_cart AS (
    {{ count_add_to_carts_by_product(
        'add_to_cart', 'products_non_purchase_sessions', 'product_id'
    ) }}
),
/* count number of times product was added to a cart in sessions ending
in a purchase */
product_purchase_add_to_cart AS (
    {{ count_add_to_carts_by_product(
        'add_to_cart', 'products_purchase_sessions', 'product_id'
    ) }}
),
/* count number of add to carts */
product_add_to_carts AS (
    SELECT product_id,
           num_carts
    FROM (
        SELECT ppa.product_id,
               IFNULL(
                   SUM(npa.num_non_purchase_add_to_carts), 0
               ) AS num_non_purchase_carts,
               IFNULL(
                   SUM(ppa.num_purchase_add_to_carts), 0
               ) AS num_purchase_carts,
               num_non_purchase_carts+num_purchase_carts AS num_carts,
        FROM product_purchase_add_to_cart ppa
        LEFT JOIN product_non_purchase_add_to_cart npa USING (product_id)
        GROUP BY ppa.product_id
        ORDER BY product_id
    )
)
SELECT *
FROM product_add_to_carts
