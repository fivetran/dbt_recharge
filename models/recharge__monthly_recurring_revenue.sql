with aggs as (
    select 
        date_month,
        customer_id,
        round(cast(sum(charge_recurring_amount_realized) as {{ dbt.type_numeric() }}), 2) as total_recurring_charges,
        round(cast(sum(charge_one_time_amount_realized) as {{ dbt.type_numeric() }}), 2) as total_one_time_charges,
        round(cast(sum(calculated_order_recurring_amount_realized) as {{ dbt.type_numeric() }}), 2) as calculated_order_mrr,
        round(cast(sum(calculated_order_one_time_amount_realized) as {{ dbt.type_numeric() }}), 2) as calculated_order_non_mrr
    from {{ ref('recharge__customer_daily_rollup') }}
    group by 1,2
)

select *
from aggs