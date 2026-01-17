---
title: Incomes
full_width: true
---

<!-- Queries -->
```sql last_refreshed
select max(_processed_at)::string as last_refreshed
from mathews_recurring_revenue.incomes
```


<!-- UI -->
<div>
    <Note class="text-sm">
        Last refreshed at <Value data={last_refreshed} column=last_refreshed />
    </Note>
    <hr />
</div>
<LineBreak/>
