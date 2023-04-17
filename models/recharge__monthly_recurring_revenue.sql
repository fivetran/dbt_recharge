with customers as (
    select 
        distinct date_month,
        customer_id
    from {{ ref('recharge__customer_daily_rollup') }}

), billing as (
    select *
    from {{ ref('recharge__billing_history') }}

), aggs as (
    select 
        customers.date_month,
        customers.customer_id,
        cast(round(sum(case when lower(billing.order_type) = 'recurring' then billing.total_price else 0 end) as {{ dbt.type_numeric() }}), 2) as current_mrr,
        cast(round(sum(case when lower(billing.order_type) = 'checkout' then billing.total_price else 0 end) as {{ dbt.type_numeric() }}), 2) as current_non_mrr
        
    from customers
    left join billing
        on cast({{ dbt.date_trunc('month','billing.created_at') }} as date) = customers.date_month
        and billing.customer_id = customers.customer_id
    where lower(billing.order_status) not in ('error', 'skipped')
    group by 1,2

), aggs_running as (
    select 
        *,
        lag(current_mrr, 1) over(partition by customer_id order by date_month asc) as previous_mrr,
        cast(round(sum(current_mrr) over( partition by customer_id order by date_month asc) as {{ dbt.type_numeric() }}), 2) as current_mrr_running_total,
        lag(current_non_mrr, 1) over(partition by customer_id order by date_month asc) as previous_non_mrr,
        cast(round(sum(current_non_mrr) over( partition by  customer_id order by date_month asc) as {{ dbt.type_numeric() }}), 2) as current_non_mrr_running_total
    from aggs

)

select *
from aggs_running