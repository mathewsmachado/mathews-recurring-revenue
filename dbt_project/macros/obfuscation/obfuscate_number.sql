{%-
    macro obfuscate_number(
        column,
        pepper,
        slope,
        jitter,
        lower_bound=0,
        upper_bound=1000
    )
-%}
    {%- if not column -%}
        {{ exceptions.raise_compiler_error("Parameter 'column' is required.") }}
    {%- endif -%}

    {%- if not pepper -%}
        {{ exceptions.raise_compiler_error("Parameter 'pepper' is required.") }}
    {%- endif -%}

    {%- if not slope -%}
        {{ exceptions.raise_compiler_error("Parameter 'slope' is required.") }}
    {%- endif -%}

    {%- if not jitter -%}
        {{ exceptions.raise_compiler_error("Parameter 'jitter' is required.") }}
    {%- endif -%}

    ((cume_dist() over (order by {{ column }}) * ({{ lower_bound }} + mod(abs(farm_fingerprint('{{ pepper }}')), {{ upper_bound }})) * {{ slope }}) + {{ jitter }})
{%- endmacro -%}
