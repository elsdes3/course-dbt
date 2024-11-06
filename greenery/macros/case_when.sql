{%- macro case_when(when, then, else, col_new) -%}
{%- if col_new -%}
(CASE WHEN {{ when }} THEN {{ then }} ELSE {{ else }} END) AS {{ col_new }}
{%- else -%}
CASE WHEN {{ when }} THEN {{ then }} ELSE {{ else }} END
{%- endif -%}
{%- endmacro %}
