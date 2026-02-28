{%- set _processed_at = var('_processed_at', get_current_timestamp()) -%}

with source as (
    select *
    from {{ ref('int.incomes_clean') }}
),
prepared as (
    select
        * except(tran_gross),
        coalesce(tran_gross, tran_net) as tran_gross,
    from source
),
enriched as (
    select
        * except(_processed_at),
        to_hex(md5(concat(tran_category, tran_payee, tran_date))) as tran_id,
        tran_gross - tran_net as tran_taxes,
        (tran_gross - tran_net) / tran_gross * 100 as tran_taxes_pct,
        timestamp("{{ _processed_at }}") as _processed_at,
    from prepared
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
        _processed_at,
    from enriched
)
select *
from final
