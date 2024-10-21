# Week 1 Answers for Question 4

All the following queries were run against the models that were created in my personal schema in Snowflake.

## Question 4.

**Answer these questions using your staging tables you have created with dbt, using SQL queries in Snowflake.  For these short answer questions and queries create a separate readme file in your github repo with your answers.**

### Part 4a. **How many users do we have?**

Since the `user_id` is the primary key of the source `raw.public.users` table, each row in that column is unique. So
```sql
COUNT(DISTINCT(user_id))
```
is not required to get the number of users. Instead, we can simply count the number of rows (to get the number of users) using
```sql
COUNT(*)
```

Using the following query

```sql
/* since each row in users is a unique user, number of rows is number of
users */
WITH num_users AS (
    SELECT COUNT(*) AS num_users
    FROM stg_postgres_users
)
SELECT *
FROM num_users
```

there are 130 users.

### Part 4b. **On average, how many orders do we receive per hour?**

Since the `order_id` is the primary key of the source `raw.public.orders` table, each row in that column is unique. So
```sql
COUNT(DISTINCT(order_id))
```
is not required to get the number of orders. Instead, we can simply count the number of rows (to get the number of orders) using
```sql
COUNT(*)
```

Using the following query

```sql
/* get the (unique) order ID and hour when it was created (received) */
WITH order_hour AS (
    SELECT order_id,
           date_part('hour', created_at) AS order_received_hour
    FROM stg_postgres_orders
),
/* get number of orders per hour from the number of order IDs per hour */
num_orders_per_hour AS (
    SELECT order_received_hour,
           count(*) AS num_orders
    FROM order_hour
    GROUP BY order_received_hour
),
/* get the average of all hourly orders */
avg_hourly_orders AS (
    -- round number of orders to show it as an integer
    SELECT round(avg(num_orders)) AS avg_num_hourly_orders_received
    FROM num_orders_per_hour
)
SELECT *
FROM avg_hourly_orders
```

on average, 15 orders are received per hour.

### Part 4c. **On average, how long does an order take from being placed to being delivered?**

Since the `order_id` is the primary key of the source `raw.public.orders` table, each row in that column corresponds to a unique order. We can calculate the delivery time for each (unique) order by calculating the time difference between the (order) `created_at` and (order) `delivered_at` columns. Then, the overall average delivery time is the average of the delivery time for each order.

Using the following query

```sql
/* for each order, get delivery time as difference in seconds between order
creation and delivery timestamps */
WITH delivery_times AS (
    SELECT
        datediff('second', created_at, delivered_at) AS delivery_time_seconds
    FROM stg_postgres_orders
),
/* get the average delivery time in seconds across all orders */
avg_delivery_time AS (
    SELECT
        cast(
            -- round up average delivery time seconds from float to integer
            round(avg(delivery_time_seconds)) AS VARCHAR
        ) AS avg_hourly_orders_received
    FROM delivery_times
),
/* convert average delivery time from seconds to HH:MM:SS format */
avg_delivery_time_formatted AS (
    SELECT to_time(avg_hourly_orders_received) AS avg_delivery_time_hhmmss
    FROM avg_delivery_time
)
SELECT *
FROM avg_delivery_time_formatted
```

on average, an order takes 336,252 seconds (or 21 hours 24 minutes and 12 seconds, which is nearly one day) from being placed to being delivered.

### Part 4d. **How many users have only made one purchase? Two purchases? Three+ purchases? *Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.***

As seen earlier, the `order_id` is the primary key of the source `raw.public.orders` table. So, each row in that column corresponds to a unique order. Since a purchase is a single (unique) order, we get the number of purchases per user by counting the number of rows in the `orders` table per user.

With this in mind, using the following query

```sql
/* get number of purchases per user */
WITH num_purchases_per_user AS (
    SELECT user_id,
           COUNT(*) AS num_purchases
    FROM stg_postgres_orders
    GROUP BY user_id
),
/* bin number of user purchases into bins of 1, 2, 3+ purchases */
num_user_purchases_binned AS (
    SELECT *,
           (
               CASE
                   WHEN num_purchases IN (1,2)
                   THEN CAST(num_purchases AS TEXT)
                   ELSE '3+'
               END
           ) AS num_purchases_binned
    FROM num_purchases_per_user
),
/* count the number of users in each bin of user purchases */
num_users_per_bin AS (
    SELECT num_purchases_binned AS num_purchases,
           COUNT(*) AS num_users
    FROM num_user_purchases_binned
    GROUP BY num_purchases_binned
    ORDER BY num_purchases_binned
)
SELECT *
FROM num_users_per_bin
```

the number of users with
1. 1 purchase is 25
2. 2 purchases is 28
3. 3+ purchases is 71

### Part 4e. **On average, how many unique sessions do we have per hour?**

Since the `event_id` is **not** the primary key of the `raw.public.events` table, each `session_id` in that column is not unique. So we cannot simply count the number of rows using
   ```sql
   COUNT(*)
   ```
   to get the number of sessions, since this count would give the number of events. Instead
   ```sql
   COUNT(DISTINCT(event_id))
   ```
   is required.

Using the following query

```sql
/* get the (unique) session ID and hour when it was created (started) */
WITH session_hour AS (
    SELECT session_id,
           date_part('hour', created_at) AS session_start_hour
    FROM stg_postgres_events
),
/* get number of sessions per hour from the number of session IDs per hour */
num_sessions_per_hour AS (
    SELECT session_start_hour,
           count(distinct(session_id)) AS num_sessions
    FROM session_hour
    GROUP BY session_start_hour
),
/* get the average of all hourly sessions */
avg_hourly_sessions AS (
    -- round number of sessions to show it as an integer
    SELECT (avg(num_sessions)) AS avg_num_hourly_sessions
    FROM num_sessions_per_hour
)
SELECT *
FROM avg_hourly_sessions
```

on average, there are 39 unique sessions per hour.
