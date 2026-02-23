{%- macro obfuscate_string(column, pepper, output_size=16) -%}
    {% if not execute or (execute and flags.WHICH not in ['build', 'run', 'run-operation']) %}
        {{ return('') }}
    {% endif %}

    {%- set max_output_size = 64 -%}

    {%- if not column -%}
        {{ exceptions.raise_compiler_error("Parameter 'column' is required.") }}
    {%- endif -%}

    {%- if not pepper -%}
        {{ exceptions.raise_compiler_error("Parameter 'pepper' is required.") }}
    {%- endif -%}

    {%- if output_size > max_output_size -%}
        {{
            exceptions.raise_compiler_error(
                "Invalid output_size, max value is: " ~ max_output_size ~ "."
            )
        }}
    {%- endif -%}

    substr(to_hex(sha256(concat({{ column }}, '{{ pepper }}'))), 1, {{ output_size }})
{%- endmacro -%}
