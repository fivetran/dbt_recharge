with aggs as (
    select 
        distinct date_month,
        customer_id,
        round(cast(sum(subscription_amount_realized) as {{ dbt.type_numeric() }}), 2) as current_mrr,
        round(cast(sum(one_time_amount_realized) as {{ dbt.type_numeric() }}), 2) as current_non_mrr
    from {{ ref('recharge__customer_daily_rollup') }}
    group by 1,2

), aggs_running as (
    select 
        customer_id,
        date_month,
        current_mrr,
        lag(current_mrr, 1) over(partition by customer_id order by date_month asc) as previous_mrr,
        round(cast(sum(current_mrr) over( partition by customer_id order by date_month asc
            rows unbounded preceding) as {{ dbt.type_numeric() }}), 2) as current_mrr_running_total,
        current_non_mrr,
        lag(current_non_mrr, 1) over(partition by customer_id order by date_month asc) as previous_non_mrr,
        round(cast(sum(current_non_mrr) over( partition by  customer_id order by date_month asc
            rows unbounded preceding) as {{ dbt.type_numeric() }}), 2) as current_non_mrr_running_total
    from aggs
)

select *
from aggs_running