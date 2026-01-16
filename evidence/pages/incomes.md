---
title: Incomes
---

```sql time_delta
select
    date_part('year', age(current_date(), '2022-01-04')) as year_part,
    date_part('month', age(current_date(), '2022-01-04')) as month_part,
    date_part('day', age(current_date(), '2022-01-04')) as day_part,
    date_diff('day', '2022-01-04', current_date()) as elapsed_days,
    date_diff('month', '2022-01-04', current_date()) as elapsed_months,
    date_diff('year', '2022-01-04', current_date()) as elapsed_years,
```

```sql tran_net_sum
    select sum(tran_net) as total
    from mathews_recurring_revenue.incomes
```

```sql tran_net_avg
    select
        tns.total / td.elapsed_years as per_year,
        tns.total / td.elapsed_months as per_month,
        tns.total / td.elapsed_days as per_day,
    from ${time_delta} as td
    cross join ${tran_net_sum} as tns
```

<LastRefreshed/>
<hr />
<LineBreak/>

You've received
**<Value data={tran_net_sum} fmt="brl2k" color="#85BB65" redNegatives="true" />**
over
**{time_delta[0].year_part}y{time_delta[0].month_part}m{time_delta[0].day_part}d**,
it is an average of:

- <Value data={tran_net_avg} fmt="brl2k" color="#85BB65" redNegatives="true" column=per_year /> per <b>year</b>;

- <Value data={tran_net_avg} fmt="brl2k" color="#85BB65" redNegatives="true" column=per_month /> per <b>month</b>;

- <Value data={tran_net_avg} fmt="brl2" color="#85BB65" redNegatives="true" column=per_day /> per <b>day</b>.
