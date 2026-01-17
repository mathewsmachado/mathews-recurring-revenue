---
title: Incomes
full_width: true
---

<script>
    $: ACCOUNTING_LIFE_START_DATE = import.meta.env.VITE_ACCOUNTING_LIFE_START_DATE
</script>

<!-- Queries -->
```sql last_refreshed
select timezone('Etc/UTC', max(_processed_at))::string as last_refreshed
from mathews_recurring_revenue.incomes
```

```sql time_delta
with base as (
    select age(current_date(), '${ACCOUNTING_LIFE_START_DATE}') as time_delta
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
        accounting_year + interval 27 hour as accounting_year,
        sum(tran_net) as tran_net,
    from mathews_recurring_revenue.incomes
	group by 1
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
        accounting_year + interval 24 hour as accounting_year,
        sum(tran_net) as nvpy,
    from mathews_recurring_revenue.incomes
	group by 1
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
    accounting_month + interval 24 hour as accounting_month,
    sum(tran_net) as nvpm,
from mathews_recurring_revenue.incomes
group by 1
```

```sql net_value_by_year_by_category
select
    string_split(accounting_year, ' ')[1] as accounting_year,
    tran_category,
    sum(tran_net) as tran_net
from mathews_recurring_revenue.incomes
group by 1, 2
order by 1 desc, 3 desc
```

```sql net_value_by_month_by_category
select
    string_split(accounting_month, ' ')[1] as accounting_month,
    tran_category,
    sum(tran_net) as tran_net
from mathews_recurring_revenue.incomes
group by 1, 2
order by 1 desc, 3 desc
```

```sql accounting_year
select distinct string_split(accounting_year, ' ')[1] as accounting_year from mathews_recurring_revenue.incomes
```

```sql accounting_month
select distinct string_split(accounting_month, ' ')[1] as accounting_month from mathews_recurring_revenue.incomes
```

```sql accounting_status
select distinct accounting_status from mathews_recurring_revenue.incomes
```

```sql tran_category
select distinct tran_category from mathews_recurring_revenue.incomes
```

```sql tran_payer
select distinct tran_payer from mathews_recurring_revenue.incomes
```

```sql tran_payee
select distinct tran_payee from mathews_recurring_revenue.incomes
```

```sql tran_payer_payee_relation
select distinct tran_payer_payee_relation from mathews_recurring_revenue.incomes
```

```sql tran_currency
select distinct tran_currency from mathews_recurring_revenue.incomes
```

```sql incomes
select
    * exclude(accounting_year, accounting_month),
    string_split(accounting_year, ' ')[1] as accounting_year,
    string_split(accounting_month, ' ')[1] as accounting_month,
from mathews_recurring_revenue.incomes
where
    (tran_payer in ${inputs.tran_payer.value} or '%' in ${inputs.tran_payer.value}) and
    (tran_payee in ${inputs.tran_payee.value} or '%' in ${inputs.tran_payee.value}) and
    (tran_payer_payee_relation in ${inputs.tran_payer_payee_relation.value} or '%' in ${inputs.tran_payer_payee_relation.value}) and
    (tran_category in ${inputs.tran_category.value} or '%' in ${inputs.tran_category.value}) and
    (tran_currency in ${inputs.tran_currency.value} or '%' in ${inputs.tran_currency.value}) and
    (string_split(accounting_year, ' ')[1] in ${inputs.accounting_year.value} or '%' in ${inputs.accounting_year.value})
    (string_split(accounting_month, ' ')[1] in ${inputs.accounting_month.value} or '%' in ${inputs.accounting_month.value})
    (accounting_status in ${inputs.accounting_status.value} or '%' in ${inputs.accounting_status.value})
order by accounting_month desc, tran_net desc
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
    title='NVbYbC'
    subtitle='Net Value by Year by Category'
    data={net_value_by_year_by_category}
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

<Details title='NVbMbC (Net Value by Month by Category)' open=false>
    <DataTable
        data={net_value_by_month_by_category}
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
    <Dropdown
        data={accounting_year}
        name=accounting_year
        value=accounting_year
        order='accounting_year desc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={accounting_month}
        name=accounting_month
        value=accounting_month
        order='accounting_month desc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={accounting_status}
        name=accounting_status
        value=accounting_status
        order='accounting_status asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={tran_category}
        name=tran_category
        value=tran_category
        order='tran_category asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={tran_payer}
        name=tran_payer
        value=tran_payer
        order='tran_payer asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={tran_payee}
        name=tran_payee
        value=tran_payee
        order='tran_payee asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={tran_payer_payee_relation}
        name=tran_payer_payee_relation
        value=tran_payer_payee_relation
        order='tran_payer_payee_relation asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <Dropdown
        data={tran_currency}
        name=tran_currency
        value=tran_currency
        order='tran_currency asc'
        multiple=true
        disableSelectAll=true
        defaultValue="%"
    >
        <DropdownOption value="%" valueLabel="All"/>
    </Dropdown>

    <DataTable
        data={incomes}
        search=true
        sort='accounting_month desc'
        groupBy=accounting_month
        groupType=section
        formatColumnTitles=false
    />
</Details>
