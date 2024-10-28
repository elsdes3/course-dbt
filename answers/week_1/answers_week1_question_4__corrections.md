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
/* get the (unique) session ID and year, month, day and hour when it was
created (started) */
WITH orders_with_datetime_attributes AS (
    SELECT order_id,
           date_part('year', created_at) AS order_created_at_year,
           date_part('month', created_at) AS order_created_at_month,
           date_part('day', created_at) AS order_created_at_day,
           date_part('hour', created_at) AS order_created_at_hour
    FROM stg_postgres_orders
),
/* get number of sessions per day per hour from the session ID */
num_orders_per_day_per_hour AS (
    SELECT order_created_at_year,
           order_created_at_month,
           order_created_at_day,
           order_created_at_hour,
           count(distinct(order_id)) AS num_orders
    FROM orders_with_datetime_attributes
    GROUP BY ALL
),
/* get the average of hourly sessions, across all days */
avg_hourly_orders AS (
    SELECT avg(num_orders) As avg_num_orders_per_hour,
           round(avg(num_orders)) As avg_num_orders_per_hour_rounded
    FROM num_orders_per_day_per_hour
)
SELECT *
FROM avg_hourly_orders
```

on average, 7.52 (rounded to 8) orders are received per hour.

### Part 4c. **On average, how long does an order take from being placed to being delivered?**

Since the `order_id` is the primary key of the source `raw.public.orders` table, each row in that column corresponds to a unique order. We can calculate the delivery time for each (unique) order by calculating the time difference between the (order) `created_at` and (order) `delivered_at` columns. Then, the overall average delivery time is the average of the delivery time for each order.

Using the following query

```sql
/* for each delivered order, get delivery time as difference in seconds
between order creation and delivery timestamps */
WITH delivery_times AS (
    SELECT
        datediff('second', created_at, delivered_at) AS delivery_time_seconds
    FROM stg_postgres_orders
    WHERE delivered_at IS NOT NULL
),
/* get the average delivery time in seconds across all orders */
avg_delivery_time AS (
    SELECT avg(delivery_time_seconds) AS avg_delivery_time_seconds
    FROM delivery_times
),
/* convert average delivery time from total seconds to days, hours, minutes
and seconds */
avg_delivery_time_formatted AS (
    SELECT -- average delivery time in seconds
           round(avg_delivery_time_seconds) AS avg_delivery_time_seconds,
           -- get whole number of days
           floor(avg_delivery_time_seconds/60/60/24) as days,
           -- get whole number of hours
           floor(avg_delivery_time_seconds/60/60%24) as hours,
           -- get whole number of minutes
           floor(avg_delivery_time_seconds/60%60) as minutes, 
           -- get whole number of seconds
           floor(avg_delivery_time_seconds%60) as seconds
    FROM avg_delivery_time
)
SELECT *
FROM avg_delivery_time_formatted
```

on average, an order takes 336,252 seconds (or 3 days 21 hours 24 minutes and 11 seconds) from being placed to being delivered.

**Notes**

1. The average delivery time should be calculated from delivered orders, which have a non-`NULL` delivery time (`delivered_at`). Without the `WHERE` clause
   ```sql
   WHERE delivered_at IS NOT NULL
   ```
   orders that are not delivered give a `delivery_time_seconds` that is `NULL`. Snowflake's `AVG` function ignores `NULL` values when calculating the average. So, the correct average delivery time in seconds is calculated even if this `WHERE` clause is ignored. However, for clarity, this `WHERE` clause is kept in the query.

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
/* get the (unique) session ID and year, month, day and hour when it was
created (started) */
WITH sessions_with_datetime_attributes AS (
    SELECT session_id,
           date_part('year', created_at) AS session_start_year,
           date_part('month', created_at) AS session_start_month,
           date_part('day', created_at) AS session_start_day,
           date_part('hour', created_at) AS session_start_hour
    FROM stg_postgres_events
),
/* get number of sessions per day per hour from the session ID */
num_sessions_per_day_per_hour AS (
    SELECT session_start_year,
           session_start_month,
           session_start_day,
           session_start_hour,
           count(distinct(session_id)) AS num_sessions
    FROM sessions_with_datetime_attributes
    GROUP BY ALL
),
/* get the average of hourly sessions, across all days */
avg_hourly_sessions AS (
    SELECT avg(num_sessions) As avg_num_sesions_per_hour,
           round(avg(num_sessions)) As avg_num_sesions_per_hour_rounded
    FROM num_sessions_per_day_per_hour
)
SELECT *
FROM avg_hourly_sessions
```

on average, there are 16.33 (rounded to 16) unique sessions per hour.
