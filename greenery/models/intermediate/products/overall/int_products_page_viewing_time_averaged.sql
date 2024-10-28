/* get time spent on page for all events in a session */
WITH times_spent_on_page_per_session AS (
    SELECT session_id,
           product_id,
           event_type,
           -- get timestamp of current event in session
           created_at,
           -- get timestamp of next event in session
           LAG(created_at, -1) OVER(
               PARTITION BY session_id ORDER BY created_at
           ) AS created_at_next_page,
           -- get time difference between successive events in session
           datediff(
               'second', created_at, created_at_next_page
           ) AS time_on_page_seconds
    FROM {{ ref('stg_postgres_events') }}
),
/* get average time spent on page per product */
avg_time_on_product_page AS (
    SELECT product_id,
           ROUND(AVG(time_on_page_seconds)) AS avg_time_on_page_seconds,
           CAST(
               ROUND(STDDEV(time_on_page_seconds)) AS INTEGER
           ) AS std_time_on_page_seconds
    FROM times_spent_on_page_per_session
    -- get events where the product page is being viewed
    WHERE event_type IN ('page_view')
    GROUP BY ALL
)
SELECT *
FROM avg_time_on_product_page
