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

```sql net_value_per_year
with grouped as (
	select
        concat(year(accounting_month), '-01-01')::date + interval 27 hour as accounting_year,
        sum(tran_net) as nvpy,
    from mathews_recurring_revenue.incomes
	group by all
),
lagged as (
    select
        accounting_year,
        nvpy,
        lag(nvpy, 1) over(order by accounting_year) as nvpy_prev,
    from grouped
)
select
    accounting_year,
    nvpy,
    round(coalesce((nvpy - nvpy_prev) / nvpy_prev * 100, 0), 2) as nvpy_delta
from lagged
```

```sql net_value_per_month
select
    accounting_month::date + interval 27 hour as accounting_month,
    sum(tran_net) as nvpm,
from mathews_recurring_revenue.incomes
group by all
```

```sql net_value_by_category_by_year
select
    (concat(year(accounting_month), '-01-01')::date + interval 27 hour)::string as accounting_year,
    tran_category,
    sum(tran_net) as tran_net
from mathews_recurring_revenue.incomes
group by all
order by 1 desc, 3 desc
```

```sql net_value_by_category_by_month
select
    (accounting_month + interval 27 hour)::string as accounting_month,
    tran_category,
    sum(tran_net) as tran_net
from mathews_recurring_revenue.incomes
group by all
order by 1 desc, 3 desc
```

```sql incomes
select *
from mathews_recurring_revenue.incomes
order by tran_date desc
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

<div class="grid grid-cols-1 xl:grid-cols-2 gap-4">
    <BarChart
        title='NVpY'
        subtitle='Net Value per Year'
        data={net_value_per_year}
        y=nvpy
        x=accounting_year
        labels=true
        labelFmt=brl2k
        labelPosition=inside
    >
        {#each net_value_per_year as nvpy}
            <ReferenceArea
                xMin={nvpy.accounting_year}
                xMax={nvpy.accounting_year}
                label={nvpy.nvpy_delta > 0 ? `(+${nvpy.nvpy_delta}%)` : `(${nvpy.nvpy_delta}%)`}
                labelColor={nvpy.nvpy_delta >= 0 ? '#16A34A' : '#FF0000'}
            />
        {/each}
    </BarChart>

    <LineChart
        title='NVpM'
        subtitle='Net Value per Month'
        data={net_value_per_month}
        y=nvpm
        x=accounting_month
        labels=true
        labelFmt=brl2k
        labelPosition=above
    />
</div>
<LineBreak/>

<DataTable
    title='NVbCbY'
    subtitle='Net Value by Category Year'
    data={net_value_by_category_by_year}
    search=true
    subtotals=true
    sort='accounting_year desc'
    groupBy=accounting_year
    groupType=section
>
	<Column id=accounting_year />
	<Column id=tran_category  totalAgg=count totalFmt='0 "categories"' /> 
	<Column id=tran_net fmt=brl2 /> 
</DataTable>
<LineBreak/>

<Details title='NVbCbM (Net Value by Category Month)' open=false>
    <DataTable
        data={net_value_by_category_by_month}
        search=true
        subtotals=true
        sort='accounting_month desc'
        groupBy=accounting_month
        groupType=section
    >
        <Column id=accounting_month />
        <Column id=tran_category  totalAgg=count totalFmt='0 "categories"' /> 
        <Column id=tran_net fmt=brl2 />
    </DataTable>
</Details>
<LineBreak/>

<Details title="Incomes" open=false>
    <DataTable data={incomes} formatColumnTitles=false />
</Details>
