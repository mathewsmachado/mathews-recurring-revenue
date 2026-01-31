{%- macro random_float64(lower_bound=0, upper_bound=1000) -%}
    (
        {{ lower_bound }} +
        (abs(farm_fingerprint(generate_uuid())) / pow(2, 63)) *
        ({{ upper_bound }} - {{ lower_bound }})
    )
{%- endmacro -%}
