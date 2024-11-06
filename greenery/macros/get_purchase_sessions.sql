{% macro get_purchase_sessions(cte_name) %}
    SELECT DISTINCT(session_id) AS session_id
    FROM {{ cte_name }}
    WHERE event_type IN ('checkout', 'package_shipped')
{% endmacro %}
