{%- macro add_columns(column1, column2, col_name_new) -%}
({{column1}} + {{column2}}) AS {{ col_name_new }}
{%- endmacro %}
