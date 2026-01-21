{%- set _processed_at = var('_processed_at', get_current_timestamp()) -%}

with source as (
    select *
    from {{ source('raw', 'google_sheets__incomes') }}
),
cleaned as (
    select
        -- date
        date(nullif(trim(tran_date), '')) as tran_date,
        date(nullif(trim(accounting_month), '')) as accounting_month,

        -- float64
        cast(nullif(trim(tran_net), '') as float64) as tran_net,
        cast(nullif(trim(tran_gross), '') as float64) as tran_gross,

        -- string
        nullif(trim(tran_payer), '') as tran_payer,
        nullif(trim(tran_payee), '') as tran_payee,
        nullif(trim(tran_payer_payee_relation), '') as tran_payer_payee_relation,
        nullif(trim(tran_category), '') as tran_category,
        nullif(trim(tran_detail), '') as tran_detail,
        nullif(trim(tran_currency), '') as tran_currency,
        nullif(trim(tran_gross_delta_category), '') as tran_gross_delta_category,
        nullif(trim(tran_gross_delta_detail), '') as tran_gross_delta_detail,
        nullif(trim(accounting_status), '') as accounting_status,
    from source
),
filtered as (
    select *
    from cleaned
    where concat(tran_category, tran_payee, tran_date) is not null
),
enriched as (
    select
        *,
        date_trunc(accounting_month, year) as accounting_year,
        timestamp("{{ _processed_at }}") as _processed_at
    from filtered
    where concat(tran_category, tran_payee, tran_date) is not null
),
final as (
    select
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
        accounting_year,
        accounting_month,
        accounting_status,
        _processed_at
    from enriched
)
select *
from final
