{%- set _ts = var('_ts', get_current_timestamp()) -%}

with final as (
    select
        cast(nullif(trim(id), '') as int64) as id,
        nullif(trim(name), '') as name,
        cast(nullif(trim(age), '') as int64) as age,
        split(nullif(trim(role), ''), ',') as role,
        timestamp('{{ _ts }}') as _ts
    from {{ source('google_sheets_raw', 'test_spreadsheet') }}
)
select *
from final
