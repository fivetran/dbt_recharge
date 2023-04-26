with spine as (
    select *
    from {{ ref('int_recharge__customer_daily_rollup') }}

), billing as (
    select 
        *,
        case when lower(order_type) = 'recurring' and lower(order_status) not in ('error', 'cancelled', 'queued') 
            then charge_total_price - charge_total_refunds
            else 0 end as charge_recurring_net_amount,
        case when lower(order_type) = 'checkout' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then charge_total_price - charge_total_refunds
            else 0 end as charge_one_time_net_amount,
        case when lower(order_type) = 'recurring' and lower(order_status) not in ('error', 'cancelled', 'queued') 
            then calculated_order_total_price - calculated_order_total_refunds
            else 0 end as calculated_order_recurring_net_amount,
        case when lower(order_type) = 'checkout' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then calculated_order_total_price - calculated_order_total_refunds
            else 0 end as calculated_order_one_time_net_amount
    from {{ ref('recharge__billing_history') }}

), customers as (
    select 
        customer_id,
        first_charge_processed_at
    from {{ ref('recharge__customer_details') }}

), aggs as (
    select
        spine.customer_id,
        spine.date_day,
        spine.date_week,
        spine.date_month,
        spine.date_year,
        count(billing.order_id) as no_of_orders,
        count(case when lower(billing.order_type) = 'recurring' then 1 else null end) as recurring_orders,
        count(case when lower(billing.order_type) = 'checkout' then 1 else null end) as one_time_orders,
        coalesce(sum(billing.charge_total_price), 0) as total_charges,
        {% set cols = ['charge_total_price', 'charge_total_discounts', 'charge_total_tax', 'charge_total_refunds',
            'calculated_order_total_discounts', 'calculated_order_total_tax', 'calculated_order_total_price', 
            'calculated_order_total_refunds', 'order_line_item_total', 'order_item_quantity', 'charge_recurring_net_amount', 
            'charge_one_time_net_amount', 'calculated_order_recurring_net_amount', 'calculated_order_one_time_net_amount'] %}
        {% for col_name in cols %}
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.{{col_name}} else 0 end) as {{ dbt.type_numeric() }}), 2)
                as {{col_name}}_realized
            {{ ',' if not loop.last -}}
        {% endfor %}
    from spine
    left join billing
        on cast({{ dbt.date_trunc('day','billing.order_processed_at') }} as date) = spine.date_day
        and billing.customer_id = spine.customer_id
    {{ dbt_utils.group_by(5) }}

), aggs_running as (
    select
        *,
        {% for col_name in cols %}
            round(cast(sum({{col_name}}_realized) over (partition by customer_id order by date_day asc 
                rows unbounded preceding) as {{ dbt.type_numeric() }}), 2)
                as {{col_name}}_running_total
            {{ ',' if not loop.last -}}
        {% endfor %}
    from aggs

), active_months as (
    select
        aggs_running.*,
        round(cast({{ dbt.datediff("customers.first_charge_processed_at", "aggs_running.date_day", "day") }} / 30 
            as {{ dbt.type_numeric() }}), 2)
            as active_months_to_date
    from aggs_running
    left join customers
        on customers.customer_id = aggs_running.customer_id
)

select * 
from active_months