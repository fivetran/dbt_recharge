with customers as (
    select *
    from {{ var('customer') }}

), billing as (
    select * 
    from {{ ref('recharge__billing_history') }}

-- Agg'd on customer_id
), order_aggs as ( 
    select 
        customer_id,
        count(order_id) as total_orders,
        round(cast(sum(total_price) as {{ dbt.type_numeric() }}), 2) as total_amount_ordered,
        round(cast(avg(total_price) as {{ dbt.type_numeric() }}), 2) as avg_order_amount,
        round(cast(avg(order_item_quantity) as {{ dbt.type_numeric() }}), 2) as avg_item_quantity_per_order,
        round(cast(sum(order_line_item_total) as {{ dbt.type_numeric() }}), 2) as total_order_line_item_total,
        round(cast(avg(order_line_item_total) as {{ dbt.type_numeric() }}), 2) as avg_order_line_item_total,
        round(cast(sum(total_tax) as {{ dbt.type_numeric() }}), 2) as total_amount_taxed,
        round(cast(sum(total_discounts) as {{ dbt.type_numeric() }}), 2) as total_amount_discounted,
        round(cast(sum(total_refunds) as {{ dbt.type_numeric() }}), 2) as total_refunds,
        count(case when lower(billing.order_type) = 'checkout' then 1 else null end) as total_one_time_purchases

    from billing
    where lower(order_status) not in ('error', 'cancelled', 'queued') --possible values: success, error, queued, skipped, refunded or partially_refunded
    group by 1

), charge_aggs as (
    select 
        customer_id,
        count(distinct charge_id) as charges_count,
        round(cast(cast(sum(total_price) as {{ dbt.type_float() }}) as {{ dbt.type_numeric() }}), 2) as total_amount_charged 
        
    from billing
    where lower(charge_status) not in ('error', 'skipped', 'queued')
    group by 1

), subscriptions as (
    select 
        customer_id,
        count(subscription_id) as calculated_active_subscriptions -- this value will differ from the recharge-provided number_active_subscriptions until we get confirmation from recharge how this is calculated on their end
    from {{ var('subscription') }} sh
    where lower(status) = 'active'
    group by 1

), joined as (
    select 
        customers.*,
        
        order_aggs.total_orders,
        order_aggs.total_amount_ordered,
        order_aggs.avg_order_amount,
        order_aggs.total_order_line_item_total,
        order_aggs.avg_order_line_item_total,
        order_aggs.avg_item_quantity_per_order, --units_per_transaction
        order_aggs.total_amount_taxed,
        order_aggs.total_amount_discounted,
        order_aggs.total_refunds,
        order_aggs.total_one_time_purchases,

        charge_aggs.total_amount_charged,
        charge_aggs.charges_count,

        round(cast(order_aggs.total_amount_ordered - order_aggs.total_refunds as {{ dbt.type_numeric() }}), 2) as total_net_spend,

        subscriptions.calculated_active_subscriptions

    from customers
    left join charge_aggs 
        on charge_aggs.customer_id = customers.customer_id
    left join order_aggs
        on order_aggs.customer_id = customers.customer_id
    left join subscriptions
        on subscriptions.customer_id = customers.customer_id
)

select * 
from joined