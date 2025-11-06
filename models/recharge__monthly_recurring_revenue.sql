with aggs as (
    select
        source_relation,
        date_month,
        customer_id,
        sum(recurring_orders) as recurring_orders,
        round(cast(sum(charge_recurring_net_amount_realized) as {{ dbt.type_numeric() }}), 2) as total_net_recurring_charges,
        round(cast(sum(calculated_order_recurring_net_amount_realized) as {{ dbt.type_numeric() }}), 2) as calculated_net_order_mrr,
        sum(one_time_orders) as one_time_orders,
        round(cast(sum(charge_one_time_net_amount_realized) as {{ dbt.type_numeric() }}), 2) as total_net_one_time_charges,
        round(cast(sum(calculated_order_one_time_net_amount_realized) as {{ dbt.type_numeric() }}), 2) as calculated_net_order_one_times
    from {{ ref('recharge__customer_daily_rollup') }}
    group by 1, 2, 3
)

select *
from aggs