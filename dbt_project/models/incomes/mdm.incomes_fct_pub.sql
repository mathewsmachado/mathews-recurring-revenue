{% set pepper = var('pepper', get_current_timestamp()) %}
{% set execution_date = var('execution_date', get_current_date()) %}
{%
    set MMRR_ACCOUNTING_LIFE_START_DATE = env_var(
        'MMRR_ACCOUNTING_LIFE_START_DATE',
        get_current_date()
    )
%}

with source as (
    select * except(accounting_month)
    from {{ ref('mdm.incomes_fct_pvt') }}
),
redistributed as (
    {{
        redistribute_evenly_across_months(
            source_table='source',
            column_name='accounting_month',
            lower_bound=MMRR_ACCOUNTING_LIFE_START_DATE,
            upper_bound=execution_date
        )
    }}
),
obfuscated as (
    select
        -- without change
        tran_id,
        accounting_status,
        _processed_at,

        -- null
        null as tran_payer,
        null as tran_payee,
        null as tran_payer_payee_relation,
        null as tran_detail,
        null as tran_currency,

        -- string
        {{ obfuscate_string('tran_category', pepper) }} as tran_category,
        {{
            obfuscate_string('tran_gross_delta_category', pepper)
        }} as tran_gross_delta_category,
        {{
            obfuscate_string('tran_gross_delta_detail', pepper)
        }} as tran_gross_delta_detail,

        -- date
        accounting_month,
        date_trunc(accounting_month, year) as accounting_year,
        safe.date(
            extract(year from accounting_month),
            extract(month from accounting_month),
            extract(day from tran_date)
        ) as tran_date,

        -- float64
        {{ random_float64() }} as tran_gross,
        {{ random_float64() }} as tran_net,
        {{ random_float64() }} as tran_taxes,
        {{ random_float64(upper_bound=100) }} as tran_taxes_pct,
    from redistributed
),
final as (
    select
        tran_id,
        tran_date,
        tran_payer,
        tran_payee,
        tran_payer_payee_relation,
        tran_category,
        tran_detail,
        tran_currency,
        tran_net,
        tran_gross,
        tran_gross_delta_category,
        tran_gross_delta_detail,
        tran_taxes,
        tran_taxes_pct,
        accounting_year,
        accounting_month,
        accounting_status,
        _processed_at
    from obfuscated
)
select *
from final
