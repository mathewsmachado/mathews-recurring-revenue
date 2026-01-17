---
title: Incomes
full_width: true
---

<!-- Queries -->
```sql last_refreshed
select max(_processed_at)::string as last_refreshed
from mathews_recurring_revenue.incomes
```

```sql time_delta
with base as (
    select age(current_date(), '2022-01-04') as time_delta
)
select
    concat(
        date_part('year', time_delta),
        'y',
        date_part('month', time_delta),
        'm',
        date_part('day', time_delta),
        'd'
    ) as time_delta
from base
```

```sql net_value_cumulated_per_year
with grouped as (
	select
        concat(year(accounting_month), '-01-01')::date + interval 27 hour as accounting_year,
        sum(tran_net) as tran_net,
    from mathews_recurring_revenue.incomes
	group by all
)
select
    accounting_year,
    sum(tran_net) over(order by accounting_year) as nvcpy,
from grouped
order by 1 desc
```

<!-- UI -->
<div>
    <Note class="text-sm">
        Last refreshed at <Value data={last_refreshed} column=last_refreshed />
    </Note>
    <hr />
</div>
<LineBreak/>

<div class="flex justify-center">
    <BigValue data={time_delta} value=time_delta />

    <BigValue
        data={net_value_cumulated_per_year}
        value=nvcpy
        title='NVCpY'
        fmt='brl2k'
        sparkline=accounting_year
        sparklineType=bar
        sparklineColor='#16A34A'
        description='Net Value Cumulated per Year'
    />
</div>
<LineBreak/>
