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

<!-- UI -->
<div>
    <Note class="text-sm">
        Last refreshed at <Value data={last_refreshed} column=last_refreshed />
    </Note>
    <hr />
</div>
<LineBreak/>

<BigValue data={time_delta} value=time_delta />
