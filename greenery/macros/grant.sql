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
