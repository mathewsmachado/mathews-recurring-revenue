{%- macro random_number() -%}
    {% if execute %}
        {{ return(run_query('select rand()').columns[0].values()[0]) }}
    {% endif %}
{%- endmacro -%}
