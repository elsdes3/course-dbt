{%- macro label_status(ship_status) %}
{%- if ship_status == 'delivered' %}
{%- set outcome='delivered' -%}
{%- else %}
{%- set outcome='shipping' -%}
{%- endif -%}

{%- set session_col_name="num_orders_{}".format(outcome) -%}
{%- set status_filter="status='{}'".format(ship_status) -%}

SUM({{ case_when(status_filter, 1, 0, '') }}) AS {{ session_col_name }}
{%- endmacro -%}
