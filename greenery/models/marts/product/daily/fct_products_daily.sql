/* get daily product page views and orders */
WITH daily_product_summary_sorted AS (
    SELECT pn.name AS product_name,
           dpv.created_at_date,
           dpv.num_page_views,
           dpv.num_orders
    FROM {{ ref('int_products_daily_totals') }} dpv
    -- join to get product name instead of product ID
    INNER JOIN stg_postgres_products pn USING (product_id)
    -- sort to show top-performing prducts first
    ORDER BY created_at_date ASC, num_orders DESC
)
SELECT *
FROM daily_product_summary_sorted
