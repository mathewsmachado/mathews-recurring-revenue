{%- set _processed_at = var('_processed_at', get_current_timestamp()) -%}

with source as (
    select *
    from {{ source('stg', 'google_sheets__incomes') }}
),
cleaned as (
    select
        -- date
        date(nullif(trim(tran_date), '')) as tran_date,
        date(nullif(trim(accounting_month), '')) as accounting_month,

        -- float64
        cast(nullif(trim(tran_amount_net), '') as float64) as tran_amount_net,
        cast(nullif(trim(tran_amount_gross), '') as float64) as tran_amount_gross,

        -- string
        nullif(trim(tran_payer), '') as tran_payer,
        nullif(trim(tran_payee), '') as tran_payee,
        nullif(trim(tran_payer_payee_relation), '') as tran_payer_payee_relation,
        nullif(trim(tran_category), '') as tran_category,
        nullif(trim(tran_detail), '') as tran_detail,
        nullif(trim(tran_currency), '') as tran_currency,
        nullif(trim(tran_amount_gross_variation_category), '') as tran_amount_gross_variation_category,
        nullif(trim(tran_amount_gross_variation_detail), '') as tran_amount_gross_variation_detail,
        nullif(trim(accounting_status), '') as accounting_status
    from source
),
enriched as (
    select
        *,
        to_hex(md5(concat(tran_category, tran_payee, tran_date))) as tran_id,
        timestamp("{{ _processed_at }}") as _processed_at
    from cleaned
),
filtered as (
    select *
    from enriched
    where tran_id is not null
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
    from filtered
)
select *
from filtered