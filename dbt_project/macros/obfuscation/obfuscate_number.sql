{%-
    macro obfuscate_number(
        column,
        slope,
        jitter,
        salt,
        lower_bound,
        upper_bound
    )
-%}
    (
        (
            cume_dist() over (order by {{ column }})
            * ({{ lower_bound }} + mod(abs(farm_fingerprint('{{ salt }}')), {{ upper_bound }}))
            * {{ slope }}
        ) + {{ jitter }}
    )
{%- endmacro -%}
