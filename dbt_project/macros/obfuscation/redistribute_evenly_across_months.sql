{%-
    macro redistribute_evenly_across_months(
        source_table=None,
        column_name=None,
        lower_bound=None,
        upper_bound=None
    )
-%}
    {% if not execute or (execute and flags.WHICH not in ['build', 'run', 'run-operation']) %}
        {{ return('') }}
    {% endif %}

    {%- if not source_table -%}
        {{ exceptions.raise_compiler_error("Parameter 'source_table' is required.") }}
    {%- endif -%}

    {%- if not column_name -%}
        {{ exceptions.raise_compiler_error("Parameter 'column_name' is required.") }}
    {%- endif -%}


    {%- if not lower_bound -%}
        {{ exceptions.raise_compiler_error("Parameter 'lower_bound' is required.") }}
    {%- endif -%}

    {%- if not upper_bound -%}
        {{ exceptions.raise_compiler_error("Parameter 'upper_bound' is required.") }}
    {%- endif -%}

    with parameterized as (
        select
            *,
            date_trunc(date('{{ lower_bound }}'), month) as lower_bound,
            date_trunc(date('{{ upper_bound }}'), month) as upper_bound,
        from {{ source_table }}
    ),
    metrified as (
        select
            *,
            row_number() over () - 1 as row_num,
            count(1) over () as rows_count,
            date_diff(upper_bound, lower_bound, month) + 1 as months_count
        from parameterized
    ),
    calculated as (
        select
            *,
            cast(floor(row_num * months_count / rows_count) as int64) as months_to_add
        from metrified
    ),
    reassigned as (
        select
            *,
            date_add(lower_bound, interval months_to_add month) as {{ column_name }}
        from calculated
    )
    select *
    from reassigned
{%- endmacro -%}
