{%- macro get_current_date() -%}
    {{ return(get_current_timestamp().date()) }}
{%- endmacro -%}
