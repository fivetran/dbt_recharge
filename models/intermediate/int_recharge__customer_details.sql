with base as (
    select *
    from {{ var('customer') }}

), customers as (
    select
        base.*,
        case when active_subscriptions > 0 then true 
            else false end as is_currently_subscribed,
        case when created_at > cast({{ dbt_date.n_days_ago(30) }} as {{ dbt.type_timestamp() }}) 
            then true
            else false end as is_new_customer
    from base

), orders as (
    select 
        customer_id,
        count(order_id) as total_orders
    from {{ var('order') }}
    group by 1

), one_time_purchases as (
    select 
        customer_id,
        count(one_time_product_id) as total_one_time_purchases
    from {{ var('one_time_product') }}
    group by 1

), charges as (
    select 
        customer_id,
        sum(total_price) as total_charges, --what is total charge vs total paid, do we also want subtotal?
        sum(total_line_items_price) as total_order_value, --not sure about this name
        avg(total_line_items_price) as avg_order_value, --no tax, discounts, shipping
        sum(total_discounts) as total_discounts,
        sum(total_tax) as total_tax,
        --best way to calc Units Per Transaction??
        null as units_per_transaction --placeholder
    from {{ var('charge') }}
    group by 1

), joined as (
    select 
        customers.*,
        orders.total_orders,
        one_time_purchases.total_one_time_purchases,
        charges.total_charges,
        charges.total_order_value,
        charges.avg_order_value,
        charges.total_discounts,
        charges.total_tax,
        charges.units_per_transaction

    from customers
    left join orders 
        on orders.customer_id = customers.customer_id
    left join one_time_purchases
        on one_time_purchases.customer_id = customers.customer_id
    left join charges
        on charges.customer_id = customers.customer_id
)

select * 
from joined