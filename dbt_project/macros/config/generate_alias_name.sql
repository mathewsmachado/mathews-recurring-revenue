{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {%- if node.resource_type == 'model' and '.' not in node.name -%}
        {{
            exceptions.raise_compiler_error(
                'Model name "' ~ node.name ~ '" is invalid, ' ~
                'it must be named like "<dataset_name>.<table_name>".'
            )
        }}
    {%- elif node.resource_type == 'model' and '.' in node.name -%}
        {{ node.name.split('.')[1] }}
    {%- elif custom_alias_name -%}
        {{ custom_alias_name | trim }}
    {%- else -%}
        {{ node.name }}
    {%- endif -%}
{%- endmacro %}
