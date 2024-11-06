# Week 3 Answers (Part 2)

## Background

We're getting really excited about dbt macros after learning more about them and want to apply them to improve our dbt project.

## Question

**Create a macro to simplify part of a model(s). Think about what would improve the usability or modularity of your code by applying a macro. Large case statements, or blocks of SQL that are often repeated make great candidates. Document the macro(s) using a `.yml` file in the macros directory.**

I used custom macros to reduce the number of lines of SQL required to define a model. The macros are documented in `macros/schema.yml`.

1. I wrote nine macros and used them to reduce a total of 171 lines of SQL (across multiple data models) to 64 lines (a reduction by 63%). One macro (`macros/get_conversion_rates`) was used to implement an entire data model and this macro was re-used across two models, so this macro alone reduced 96 lines of SQL to 16 lines (83% reduction).
2. The nine macros covered eight data models.
3. Seven of the nine macros reduced the number of lines of SQL and two macros increased the number of lines of SQL.
4. Macros were used in five `marts` models and in five `intermediate` models.
5. Eight of the nine macros were directly used in the SQL used to define a model. One macro (`case_when`, which implements a SQL `CASE` expression with a single `WHEN` + `THEN` clause) was a nested macro, so it was only called by another macro; it was not directly used in the SQL used to define a model.
6. Two macro were re-used (used in two different data models)
   - `macros/add_columns`
     - in one `marts` model and in one `intermediate` model
   - `macros/get_conversion_rates`
     - in two `marts` models

I did not use macros from DBT packages.

Below are the uses of the custom macros that I wrote (excluding nested macros)

1. `marts/marketing/fct_user_orders.sql` replaced by `label_status`
   - without macro (6 lines of SQL)
     ```sql
     -- get total number of delivered orders by user
     SUM(
         CASE WHEN status = 'delivered' THEN 1 ELSE 0 END
     ) AS num_orders_delivered
     -- get total number of orders by user that are shipping
     SUM(
         CASE WHEN status = 'shipped' THEN 1 ELSE 0 END
     ) AS num_orders_shipping
     ```
   - with macro `label_status` (2 lines of SQL, this is a nested macro, that calls another macro named `case_when`)
     ```sql
     -- get total number of delivered orders by user
     {{ label_status('delivered') }},
     -- get total number of orders by user that are shipping
     {{ label_status('shipped') }},
     ```
2. `intermediate/products/overall/int_events_sessions_aggregated_to_product.sql`
   - without macro (26 lines of SQL)
     ```sql
     /* count number of sessions not ending in a purchase in which product page was
     viewed */
     product_non_purchase_page_views AS (
         SELECT product_id,
                COUNT(*) AS num_non_purchase_page_views,
                COUNT(DISTINCT(session_id)) AS num_non_purchase_page_view_sessions
         FROM products_non_purchase_sessions
         -- get page view event in product non-purchase sessions
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
     )
     ```
   - with macro `count_purchases_views_by_product` (15 lines of SQL)
     ```sql
     /* count number of sessions not ending in a purchase in which product page was
     viewed */
     product_non_purchase_page_views AS (
         {{ count_purchases_views_by_product(
             'page_view', 'products_non_purchase_sessions', 'product_id'
         ) }}
     ),
     /* count number of sessions ending in a purchase in which product page was
     viewed */
     product_purchase_page_views AS (
         {{ count_purchases_views_by_product(
             'page_view', 'products_purchase_sessions', 'product_id'
         ) }}
     ),
     /* count purchases */
     product_purchases AS (
         {{ count_purchases_views_by_product(
             'add_to_cart', 'products_purchase_sessions', 'product_id'
         ) }}
     ),
     ```
3. `intermediate/products/overall/int_events_sessions_aggregated_to_product.sql`
   - without macro (4 lines of SQL)
     ```sql
     -- count of total page views
     (
         npv.num_non_purchase_page_views
         + ppv.num_purchase_page_views
     ) AS num_page_views
     ```
   - with macro `add_columns` (5 lines of SQL)
     ```sql
     -- count of total page views
     {{ add_columns(
        'npv.num_non_purchase_page_views',
        'ppv.num_purchase_page_views',
        'num_page_views'
     ) }}
     ```
4. `intermediate/products/overall/int_products_purchase_abandoned_cart_sessions_summed.sql`
   - without macro (16 lines of SQL)
     ```sql
     /* count number of times product was added to a cart in sessions not ending
     in a purchase */
     product_non_purchase_add_to_cart AS (
         SELECT product_id,
                COUNT(*) AS num_non_purchase_add_to_carts
         FROM products_non_purchase_sessions
         -- get add-to-cart event from sessions in which product was added to cart
         WHERE event_type = 'add_to_cart'
         GROUP BY product_id
     ),
     /* count number of times product was added to a cart in sessions ending
     in a purchase */
     product_purchase_add_to_cart AS (
         SELECT product_id,
                COUNT(*) AS num_purchase_add_to_carts
         FROM products_purchase_sessions
         -- get add-to-cart event from sessions in which product was added to cart
         WHERE event_type = 'add_to_cart'
         GROUP BY product_id
     ),
     ```
   - with macro `count_add_to_carts_by_product` (10 lines of SQL)
     ```sql
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
     ```
5. `marts/product/overall/fct_products.sql`
   - without macro (4 lines of SQL)
     ```sql
     -- calculate total number of sessions (with or without a purchase)
     -- in which a product page was viewed
     (
         num_non_purchase_page_view_sessions
         +num_purchase_page_view_sessions
     ) AS num_page_view_sessions
     ```
   - with macro `add_columns` (5 lines of SQL)
     ```sql
     -- calculate total number of sessions (with or without a purchase)
     -- in which a product page was viewed
     {{ add_columns(
        'num_non_purchase_page_view_sessions',
        'num_purchase_page_view_sessions',
        'num_page_view_sessions'
     ) }}
     ```
6. `marts/product/overall/fct_products.sql`
   - without macro (10 lines of SQL)
     ```sql
     -- add high-traffic indicator per product
     (
         CASE WHEN rank_traffic <= 10 THEN True ELSE False END
     ) AS is_high_traffic,
     -- add low-conversion indicator per product
     (
         CASE
             WHEN rank_purchases >= num_products-10
             THEN True
             ELSE False
         END
     ) AS is_low_conversions
     ```
   - with macro `case_when` (9 lines of SQL)
     ```sql
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
     ```
7. `intermediate/product/overall/int_product_purchases_filtered.sql`
   - without macro (5 lines of SQL)
     ```sql
     /* get the session ID for sessions ending in a purchase */
     sessions_with_purchase AS (
         SELECT DISTINCT(session_id) AS session_id
         FROM events
         WHERE event_type IN ('checkout', 'package_shipped')
     ),
     ```
   - with macro `get_purchase_sessions` (1 line of SQL)
     ```sql
     /* get the session ID for sessions ending in a purchase */
     sessions_with_purchase AS ({{ get_purchase_sessions('events') }}),
     ```
8. `intermediate/product/overall/int_product_non_purchases_filtered.sql`
   - without macro (4 lines of SQL)
     ```sql
     -- get sessions in which the last event does not indicate a purchase
     QUALIFY (
        LAST_VALUE(event_type)
        OVER(PARTITION BY session_id ORDER BY session_id, created_at)
     ) IN ('page_view', 'add_to_cart')
     ```
  - with macro `filter_non_purchase_events` (1 line of SQL)
    ```sql
    -- get sessions in which the last event does not indicate a purchase
    filter_sessions_by_last_event(('page_view', 'add_to_cart'))
    ```
9. `marts/core/fct_conversion_rate.sql` (overall conversion rate)
   - without macro (47 lines of SQL)
     ```sql
     WITH conversion_rates AS (
         SELECT *
         FROM (
             WITH products AS (
                 SELECT 1 AS product_id,
                        'all' AS product_name
                 FROM {{ ref('stg_postgres_products') }}
             ),
             /* get conversion rate */
             product_conversion_rates AS (
                 SELECT 1 AS product_id,
                        (
                            num_non_purchase_page_view_sessions
                            +num_purchase_page_view_sessions
                        ) AS total_num_page_view_sessions,
                        num_purchases AS num_purchase_sessions,
                        (
                            100*num_purchase_sessions/total_num_page_view_sessions
                        ) AS conversion_rate
                 FROM {{ ref('int_events_sessions_aggregated_to_product') }}
             ),
             /* get first and last event timestamp */
             event_timestamp_bounds AS (
                 SELECT 1 AS product_id,
                        MIN(created_at) AS first_event,
                        MAX(created_at) AS last_event
                 FROM {{ ref('stg_postgres_events') }}
             ),
             /* combine conversion rates and event timestamp bounds */
             conversion_rates_timestamp_bounds AS (
                 SELECT p.product_name,
                        c.total_num_page_view_sessions,
                        c.num_purchase_sessions,
                        c.conversion_rate,
                        b.first_event,
                        b.last_event
                 FROM product_conversion_rates c
                 INNER JOIN event_timestamp_bounds b USING (product_id)
                 INNER JOIN products p USING (product_id)
                 ORDER BY conversion_rate DESC
             )
             SELECT *
             FROM conversion_rates_timestamp_bounds
         )
     )
     SELECT *
     FROM conversion_rates
     ```
   - with macro `get_conversion_rates` (8 lines of SQL)
     ```sql
     WITH conversion_rates AS (
         SELECT *
         FROM (
             {{ get_conversion_rates('overall') }}
         )
     )
     SELECT *
     FROM conversion_rates
     ```
10. `marts/products/overall/fct_products_conversion_rates.sql` (conversion rate per product)
    - without macro (49 lines of SQL)
    ```sql
    WITH conversion_rates AS (
        SELECT *
        FROM (
            WITH products AS (
                SELECT product_id,
                    name AS product_name
                FROM {{ ref('stg_postgres_products') }}
            ),
            /* get conversion rate */
            product_conversion_rates AS (
                SELECT product_id,
                    (
                        num_non_purchase_page_view_sessions
                        +num_purchase_page_view_sessions
                    ) AS total_num_page_view_sessions,
                    num_purchases AS num_purchase_sessions,
                    (
                        100*num_purchase_sessions/total_num_page_view_sessions
                    ) AS conversion_rate
                FROM {{ ref('int_events_sessions_aggregated_to_product') }}
            ),
            /* get first and last event timestamp */
            event_timestamp_bounds AS (
                SELECT 
                    product_id,
                    MIN(created_at) AS first_event,
                    MAX(created_at) AS last_event
                FROM {{ ref('stg_postgres_events') }}
                GROUP BY product_id
            ),
            /* combine conversion rates and event timestamp bounds */
            conversion_rates_timestamp_bounds AS (
                SELECT p.product_name,
                    c.total_num_page_view_sessions,
                    c.num_purchase_sessions,
                    c.conversion_rate,
                    b.first_event,
                    b.last_event
                FROM product_conversion_rates c
                INNER JOIN event_timestamp_bounds b USING (product_id)
                INNER JOIN products p USING (product_id)
                ORDER BY conversion_rate DESC
            )
            SELECT *
            FROM conversion_rates_timestamp_bounds
        )
    )
    SELECT *
    FROM conversion_rates
    ```
   - with macro `get_conversion_rates` (8 lines of SQL)
     ```sql
     WITH conversion_rates AS (
         SELECT *
         FROM (
             {{ get_conversion_rates('product') }}
         )
     )
     SELECT *
     FROM conversion_rates
     ```
