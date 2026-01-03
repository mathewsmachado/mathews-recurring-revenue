{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if node.resource_type == 'model' and '.' not in node.name -%}
        {{
            exceptions.raise_compiler_error(
                'Model name "' ~ node.name ~ '" is invalid, ' ~
                'it must be named like "<dataset>.<table>".'
            )
        }}
    {%- elif node.resource_type == 'model' and '.' in node.name -%}
        {{ node.name.split('.')[0] }}
    {%- elif custom_schema_name -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
