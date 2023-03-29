with base as (
    select *
    from {{ var('customer') }}

), customers as (
    select
        base.*,
        case when active_subscriptions > 0 
            then true else false end as is_currently_subscribed,
        case when {{ dbt.datediff("created_at", dbt.current_timestamp_backcompat(), "day") }} <= 30
            then true else false end as is_new_customer,
        {{ dbt_utils.safe_divide( dbt.datediff("created_at", dbt.current_timestamp_backcompat(), "day") , 30) }}
            as active_months
    from base

-- Agg'd on customer_id
), order_aggs as ( 
    select 
        customer_id,
        count(order_id) as total_orders,
        sum(total_price) as total_amount_ordered,
        avg(total_price) as avg_order_amount,
        avg(order_item_quantity) as avg_item_quantity_per_order,
        sum(order_value) as total_order_value,
        avg(order_value) as avg_order_value

    from {{ ref('recharge__balance_transactions') }}
    where upper(order_status) not in ('ERROR', 'SKIPPED', 'QUEUED') --possible values: success, error, queued, skipped, refunded or partially_refunded
    group by 1

), charge_aggs as (
    select 
        customer_id,
        count(charge_id) as charges_count,
        sum(total_price) as total_amount_charged, 
        sum(total_tax) as total_amount_taxed,
        sum(total_discounts) as total_amount_discounted,
        sum(total_refunds) as total_refunds
    from {{ var('charge') }}
    where upper(charge_status) not in ('ERROR', 'SKIPPED', 'QUEUED')
    group by 1

), one_time_purchases as (
    select
    {% if var('recharge__one_time_product_enabled', true) %}
        customer_id,
        count(one_time_product_id) as total_one_time_purchases

    from {{ var('one_time_product') }}
    group by 1

    {% else %} --cast nulls if not using one_time_product
        cast(null as {{ dbt.type_string() }}) as customer_id,
        cast(null as {{ dbt.type_int() }}) as total_one_time_purchases
    {% endif %}

), joined as (
    select 
        customers.*,
        
        order_aggs.total_orders,
        order_aggs.total_amount_ordered,
        order_aggs.avg_order_amount,
        order_aggs.total_order_value,
        order_aggs.avg_order_value,
        order_aggs.avg_item_quantity_per_order, --units_per_transaction

        charge_aggs.total_amount_charged,
        charge_aggs.total_amount_taxed,
        charge_aggs.total_amount_discounted,
        charge_aggs.total_refunds,
        
        one_time_purchases.total_one_time_purchases,

        order_aggs.total_amount_ordered - charge_aggs.total_refunds as total_net_spend

    from customers
    left join charge_aggs 
        on charge_aggs.customer_id = customers.customer_id
    left join one_time_purchases
        on one_time_purchases.customer_id = customers.customer_id
    left join order_aggs
        on order_aggs.customer_id = customers.customer_id
)

select * 
from joined