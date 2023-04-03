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
        round(sum(case when lower(transactions.order_type) = 'recurring' then transactions.total_price else 0 end), 2) as current_mrr,
        lag(current_mrr, 1) over(order by month_spine.date_month asc) as previous_mrr,
        round(sum(case when lower(transactions.order_type) = 'checkout' then transactions.total_price else 0 end), 2) as current_non_mrr,
        lag(current_non_mrr, 1) over(order by month_spine.date_month asc) as previous_non_mrr

    from month_spine
    left join transactions
        on cast({{ dbt.date_trunc('month','transactions.created_at') }} as date) = month_spine.date_month
    where lower(transactions.order_status) not in ('error', 'skipped')
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