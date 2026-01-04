{%- set _processed_at = var('_processed_at', get_current_timestamp()) -%}

with source as (
    select *
    from {{ ref('int.incomes_clean') }}
),
enriched as (
    select
        * except(_processed_at),
        to_hex(md5(concat(tran_category, tran_payee, tran_date))) as tran_id,
        timestamp("{{ _processed_at }}") as _processed_at
    from source
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
        tran_amount_net,
        tran_amount_gross,
        tran_amount_gross_variation_category,
        tran_amount_gross_variation_detail,
        accounting_month,
        accounting_status,
        _processed_at
    from enriched
)
select *
from final
