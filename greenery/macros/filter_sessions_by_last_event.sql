{% macro filter_sessions_by_last_event(event_types) -%}
    QUALIFY (
        LAST_VALUE(event_type)
        OVER(PARTITION BY session_id ORDER BY session_id, created_at)
    ) IN {{ event_types }}
{%- endmacro -%}
