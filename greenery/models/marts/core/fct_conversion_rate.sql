WITH conversion_rates AS (
    SELECT *
    FROM (
        {{ get_conversion_rates('overall') }}
    )
)
SELECT *
FROM conversion_rates
