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
        round(sum(total_price), 2) as total_amount_ordered,
        round(avg(total_price), 2) as avg_order_amount,
        round(avg(order_item_quantity), 2) as avg_item_quantity_per_order,
        round(sum(order_value), 2) as total_order_value,
        round(avg(order_value), 2) as avg_order_value,
        round(sum(total_tax), 2) as total_amount_taxed,
        round(sum(total_discounts), 2) as total_amount_discounted,
        round(sum(total_refunds), 2) as total_refunds,
        count(case when lower(billing.order_type) = 'checkout' then 1 else null end) as total_one_time_purchases

    from billing
    where lower(order_status) not in ('error', 'skipped', 'queued') --possible values: success, error, queued, skipped, refunded or partially_refunded
    group by 1

), charge_aggs as (
    select 
        customer_id,
        count(distinct charge_id) as charges_count,
        round(cast(sum(total_price) as {{ dbt.type_float() }}), 2) as total_amount_charged 
        
    from billing
    where lower(charge_status) not in ('error', 'skipped', 'queued')
    group by 1

), subscriptions as (
    select 
        customer_id,
        count(subscription_id) as calculated_active_subscriptions
    from {{ var('subscription') }} sh
    where lower(status) = 'active'
    group by 1

), joined as (
    select 
        customers.*,
        
        order_aggs.total_orders,
        order_aggs.total_amount_ordered,
        order_aggs.avg_order_amount,
        order_aggs.total_order_value,
        order_aggs.avg_order_value,
        order_aggs.avg_item_quantity_per_order, --units_per_transaction
        order_aggs.total_amount_taxed,
        order_aggs.total_amount_discounted,
        order_aggs.total_refunds,
        order_aggs.total_one_time_purchases,

        charge_aggs.total_amount_charged,
        charge_aggs.charges_count,

        order_aggs.total_amount_ordered - order_aggs.total_refunds as total_net_spend,

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