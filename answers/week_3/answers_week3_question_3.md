# Week 3 Answers (Part 3)

## Background

We're starting to think about granting permissions to our dbt models in our snowflake database so that other roles can have access to them.

# Questions

### Question 1

**Add a post hook to your project to apply grants to the role "reporting". You can use the grant macro example from this week!**

In order to create and use a `post-hook` to grant permissions to my DBT models on Snowflake to the `reporting` role, I followed the below steps

1. I created a macro in `macros/grant.sql` with the following contents
   ```sql
   {% macro grant(role_name, permission_type) %}

       {% set sql %}
           {% if permission_type == 'usage' %}
           GRANT USAGE ON SCHEMA {{ schema }} TO ROLE {{ role_name }};
           {% else %}
           GRANT SELECT ON {{ this }} TO ROLE {{ role_name }};
           {% endif %}
       {% endset %}

       {% set table = run_query(sql) %}

   {% endmacro %}
   ```
2. I added the `post-hook` to the `models` section of the `dbt_project.yml` file as follows
   ```bash
   models:
     greenery:
       # Config indicated by + and applies to all files under models/staging/
       staging:
         +materialized: view
       intermediate:
         +materialized: view
       marts:
         +materialized: table
       +post-hook:
         # apply grants to dbt models to the 'reporting' role
         - "{{ grant(role_name='reporting', permission_type='select') }}"
   ```
3. I granted the `reporting` role the [privilige to access my personal schema](https://www.ibm.com/docs/en/informix-servers/12.10?topic=privileges-usage-privilege), by [invoking the above macro (in `grant.sql`) with the keyword argument `permission_type=usage` as an operation](https://docs.getdbt.com/docs/build/hooks-operations#about-operations)
   ```bash
   $ dbt run-operation grant --args "{role_name: reporting, permission_type: usage}"'
   ```
4. I granted the `reporting` role `select` (read-only access) to each model by running all my 21 DBT models which would invoke the macro with the keyword argument `permission_type=select`
   ```bash
   # (7) staging models
   $ dbt run --select stg_postgres_order_items
   $ dbt run --select stg_postgres_users
   $ dbt run --select stg_postgres_products
   $ dbt run --select stg_postgres_promos
   $ dbt run --select stg_postgres_orders
   $ dbt run --select stg_postgres_events
   $ dbt run --select stg_postgres_addresses
   # (7) intermediate models
   $ dbt run --select int_orders_joined_to_addresses_promos
   $ dbt run --select int_products_daily_totals
   $ dbt run --select int_products_purchase_abandoned_cart_sessions_summed
   $ dbt run --select int_events_sessions_aggregated_to_product
   $ dbt run --select int_products_page_viewing_time_averaged
   $ dbt run --select int_product_purchases_filtered
   $ dbt run --select int_product_non_purchases_filtered
   # (7) marts models
   $ dbt run --select fct_orders
   $ dbt run --select fct_conversion_rate
   $ dbt run --select fct_user_orders
   $ dbt run --select fct_promo_orders
   $ dbt run --select fct_products_daily
   $ dbt run --select fct_products
   $ dbt run --select fct_products_conversion_rates
   ```

### Question 2

**To check if your grants worked you can check in the query history in the snowflake UI after your dbt run, and find the grant that ran.**

#### `USAGE` Privilige to Schema

I verified that the `reporting` role was given `USAGE` privilege to my schema by using the Snowflake query history to count the number of successful `GRANT USAGE`s that ran using

```sql
/* count number of models to which the reporting role was granted read-only
access */
SELECT COUNT(DISTINCT(query_text)) AS num_schemas_granted_access
FROM table(
    information_schema.query_history(
        END_TIME_RANGE_START=>to_timestamp_ltz('2024-11-1 21:00:00.000 -0400'),
        RESULT_LIMIT=>500
    )
)
-- get GRANT USAGEs
WHERE query_text LIKE 'GRANT USAGE%'
-- get successful GRANts
AND execution_status = 'SUCCESS'
```

which gave the following output

```sql
      SCHEMA_NAME | ROLE_GRANTED | NUM_USAGE_GRANTS
----------------- | ------------ | ----------------
<personal-schema>      reporting                  1
```

This is expected since 1 `GRANT USAGE`s was run by invoking the macro through the `post-hook` to give the `reporting` role access to my personal schema, and it ran successfully.

#### Read-Only Access to Models

I verified that my model read-only access grants to the `reporting` role worked by using the Snowflake query history to count the number of successful `GRANT SELECT`s that ran using

```sql
/* count number of models to which the reporting role was granted read-only
access */
SELECT COUNT(DISTINCT(query_text)) AS num_models_granted_access
FROM table(
    information_schema.query_history(
        END_TIME_RANGE_START=>..., RESULT_LIMTI=>...
    )
)
-- get GRANT SELECts
WHERE query_text LIKE 'GRANT SELECT%'
-- get successful GRANts
AND execution_status = 'SUCCESS'
```

which gave the following output

```sql
NUM_MODELS_GRANTED_ACCESS
-------------------------
                       21
```

As expected, 21 `GRANT SELECT`s ran successfully by invoking the macro through the `post-hook`, one for each of my DBT models.
