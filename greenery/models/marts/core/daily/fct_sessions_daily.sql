WITH users AS (
    SELECT user_id,
           address_id
    FROM {{ ref('stg_postgres_users') }}
),
addresses AS (
    SELECT address_id,
           state AS state_name
    FROM {{ ref('stg_postgres_addresses') }}
),
products AS (
    SELECT product_id,
           name AS product_name
    FROM {{ ref('stg_postgres_products') }}
),
event_users AS (
    SELECT DISTINCT(user_id) AS user_id
    FROM {{ ref('stg_postgres_events') }}
),
daily_user_sessions AS (
    SELECT *
    FROM {{ ref('int_sessions_aggregated_to_product_daily') }}
),
user_addresses AS (
     SELECT u.user_id,
            a.state_name
     FROM event_users AS u
     INNER JOIN users us USING (user_id)
     INNER JOIN addresses a USING (address_id)
),
daily_user_sessions_named AS (
    SELECT s.session_id,
           s.user_id,
           ua.state_name,
           p.product_name,
           s.created_at_date,
           s.num_page_views,
           s.num_add_to_carts,
           s.num_checkouts
    FROM daily_user_sessions AS s
    INNER JOIN user_addresses ua USING (user_id)
    INNER JOIN products p USING (product_id)
)
SELECT *
FROM daily_user_sessions_named
