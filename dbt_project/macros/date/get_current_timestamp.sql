{%- macro get_current_timestamp() -%}
    {{ return(modules.datetime.datetime.now(modules.pytz.timezone('Etc/UTC'))) }}
{%- endmacro -%}
