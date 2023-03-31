with transactions as (
    select *
    from {{ ref('recharge__balance_transactions') }}

), customers as (
    select *
    from {{ ref('recharge__customer_details') }}

), month_spine as (
    select 
        distinct cast({{ dbt.date_trunc('month','date_day') }} as date) as date_month
    from {{ ref('int_recharge__calendar_spine') }}

), aggs as (
    select 
        month_spine.date_month,
        transactions.customer_id,
        sum(case when transactions.order_type = 'RECURRING' then transactions.total_price else 0 end) as current_mrr,
        lag(current_mrr, 1) over(order by month_spine.date_month asc) as previous_mrr,
        sum(case when transactions.order_type = 'CHECKOUT' then transactions.total_price else 0 end) as current_non_mrr,
        lag(current_non_mrr, 1) over(order by month_spine.date_month asc) as previous_non_mrr

    from month_spine
    left join transactions
        on cast({{ dbt.date_trunc('month','transactions.created_at') }} as date) = month_spine.date_month
    where transactions.order_status not in ('ERROR', 'SKIPPED')
    group by 1,2

), joined as (
    select 
        aggs.*,
        customers.active_months,
        customers.created_at,
        customers.updated_at

    from aggs
    left join customers
        using(customer_id)
)

select *
from joined