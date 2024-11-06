WITH conversion_rates AS (
    SELECT *
    FROM (
        {{ get_conversion_rates('product') }}
    )
)
SELECT *
FROM conversion_rates
