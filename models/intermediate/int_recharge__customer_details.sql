with customers as (
    select *
    from {{ var('customer') }}

), transactions as (
    select * 
    from {{ ref('recharge__balance_transactions') }}

-- Agg'd on customer_id
), order_aggs as ( 
    select 
        customer_id,
        count(order_id) as total_orders,
        sum(total_price) as total_amount_ordered,
        avg(total_price) as avg_order_amount,
        avg(order_item_quantity) as avg_item_quantity_per_order,
        sum(order_value) as total_order_value,
        avg(order_value) as avg_order_value,
        sum(total_tax) as total_amount_taxed,
        sum(total_discounts) as total_amount_discounted,
        sum(total_refunds) as total_refunds,
        count(case when transactions.order_type = 'CHECKOUT' then 1 else null end) as total_one_time_purchases

    from transactions
    where upper(order_status) not in ('ERROR', 'SKIPPED', 'QUEUED') --possible values: success, error, queued, skipped, refunded or partially_refunded
    group by 1

), charge_aggs as (
    select 
        customer_id,
        count(distinct charge_id) as charges_count,
        cast(sum(total_price) as {{ dbt.type_float() }}) as total_amount_charged 
        
    from transactions
    where upper(charge_status) not in ('ERROR', 'SKIPPED', 'QUEUED')
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

        order_aggs.total_amount_ordered - order_aggs.total_refunds as total_net_spend

    from customers
    left join charge_aggs 
        on charge_aggs.customer_id = customers.customer_id
    left join order_aggs
        on order_aggs.customer_id = customers.customer_id
)

select * 
from joined