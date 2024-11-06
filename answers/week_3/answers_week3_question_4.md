# Week 3 Answers (Part 4)

## Background

After learning about dbt packages, we want to try one out and apply some macros or tests.

## Question

**Install a package (i.e. `dbt-utils`, `dbt-expectations`) and apply one or more of the macros to your project**

I used the two packages (`dbt-utils` and `dbt_expectations`) for adding tests to the data models. I first tested `staging` models to ensure quality for incoming data. Next, `intermediate` models were tested. Finally, `marts` models were tested.

I first adopted built-in (`not_null`, `unique`) or custom generic tests. The generic tests were

1. `order_before_delivery` to test chronological ordering or two timestamps
2. `positive_values` to test for positive values in a column

and are included in `tests/generic`.

I then incorporated macros from the `dbt-utils` and `dbt_expectations` packages in tests.

### Summary of Tests

Number of total tests used

1. built-in or custom = 201
2. `dbt-expectations` = 94
3. `dbt-utils` = 29

### Detailed Breakdown of Tests

Below are the tests that were used
1. `staging` (7 models)
   - 53 built-in or custom tests were used across all models
   - 37 `dbt-expectations` was used across all models
   - 5 `dbt-utils` was used across two models
   - column test summary (5/44 columns across all models were untested)
     - `stg_postgres_users` (untested columns: 1/8)
     - `stg_postgres_addresses` (untested columns: 0/5)
     - `stg_postgres_promos` (untested columns: 0/3)
     - `stg_postgres_products` (columns: 10, untested columns: 0/4)`
     - `stg_postgres_orders` (untested columns: 3/13)`
     - `stg_postgres_order_items` (untested columns: 0/3)`
     - `stg_postgres_events` (untested columns: 1/8)`
   ```bash
   # model name: (dbt-expectations, dbt-utils, built-in and/or custom)
   stg_postgres_users: (7, 0, 8)
   stg_postgres_addresses: (3, 0, 8)
   stg_postgres_promos: (5, 0, 6)
   stg_postgres_products: (13, 0, 7)
   stg_postgres_orders: (10, 3, 14)
   stg_postgres_order_items: (3, 0, 4)
   stg_postgres_events: (6, 2, 6)
   ```
2. `intermediate` (7 models)
   - 61 built-in or custom tests were used for all models
   - 22 `dbt-expectations` was used for all models
   - 5 `dbt-utils` was used for two models
   - column test summary (0/44 columns across all models were untested)
     - `int_product_purchases_filtered` (untested columns: 0/7)
     - `int_product_non_purchases_filtered` (untested columns: 0/7)
     - `int_events_sessions_aggregated_to_product` (untested columns: 0/5)
     - `int_products_page_viewing_time_averaged` (untested columns: 0/3)
     - `int_products_purchase_abandoned_cart_sessions_summed` (untested columns: 0/2)
     - `int_products_daily_totals` (untested columns: 0/5)
     - `int_orders_joined_to_addresses_promos` (untested columns: 0/15)
   ```bash
   # model name: (dbt-expectations, dbt-utils, built-in and/or custom)
   int_product_purchases_filtered: (3, 1, 9)
   int_product_non_purchases_filtered: (3, 0, 10)
   int_events_sessions_aggregated_to_product: (2, 0, 10)
   int_products_page_viewing_time_averaged: (3, 0, 6)
   int_products_purchase_abandoned_cart_sessions_summed: (2, 0, 4)
   int_products_daily_totals: (3, 0, 8)
   int_orders_joined_to_addresses_promos: (6, 4, 14)
   ```
3. `marts` (7 models)
   - 87 built-in or custom tests were used for all models
   - 35 `dbt-expectations` was used for all models
   - 19 `dbt-utils` was used for two models
   - column test summary (0/49 columns across all models were untested)
     - `fct_orders` (untested columns: 0/15)
     - `fct_conversion_rates` (untested columns: 0/6)`
     - `fct_user_orders` (untested columns: 0/12)
     - `fct_promo_orders` (untested columns: 0/8)
     - `fct_products` (untested columns: 0/10)`
     - `fct_products_conversion_rates` (untested columns: 0/6)`
     - `fct_products_daily` (untested columns: 0/4)`
   ```bash
   # model name: (dbt-expectations, dbt-utils, built-in and/or custom)
   fct_orders: (6, 1, 12)
   fct_conversion_rates: (4, 3, 8)
   fct_user_orders: (3, 8, 19)
   fct_promo_orders: (3, 1, 15)
   fct_products: (8, 2, 17)
   fct_products_conversion_rates: (2, 3, 10)
   fct_products_daily: (4, 1, 6)
   ```
