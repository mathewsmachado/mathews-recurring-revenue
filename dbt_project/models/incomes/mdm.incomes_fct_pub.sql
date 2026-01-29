{% set pepper = var('pepper', '') %}
{% set slope = var('slope', '') %}
{% set jitter = var('jitter', '') %}

with final as (
    select
        tran_id,
        tran_date,
        {{ obfuscate_string('tran_payer', pepper) }} as tran_payer,
        {{ obfuscate_string('tran_payee', pepper) }} as tran_payee,
        {{ obfuscate_string('tran_payer_payee_relation', pepper) }} as tran_payer_payee_relation,
        {{ obfuscate_string('tran_category', pepper) }} as tran_category,
        {{ obfuscate_string('tran_detail', pepper) }} as tran_detail,
        {{ obfuscate_string('tran_currency', pepper) }} as tran_currency,
        {{ obfuscate_number('tran_net', pepper, slope, jitter) }} as tran_net,
        {{ obfuscate_number('tran_gross', pepper, slope, jitter) }} as tran_gross,
        {{ obfuscate_string('tran_gross_delta_category', pepper) }} as tran_gross_delta_category,
        {{ obfuscate_string('tran_gross_delta_detail', pepper) }} as tran_gross_delta_detail,
        {{ obfuscate_number('tran_taxes', pepper, slope, jitter) }} as tran_taxes,
        {{ obfuscate_number('tran_taxes_pct', pepper, slope, jitter, upper_bound=100) }} as tran_taxes_pct,
        accounting_year,
        accounting_month,
        accounting_status,
        _processed_at
    from {{ ref('mdm.incomes_fct_pvt') }}
)
select *
from final
