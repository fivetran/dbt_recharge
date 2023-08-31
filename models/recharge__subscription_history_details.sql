with subscriptions as (
    select * 
    from {{ var('subscription_history') }}

), orders as (
    select * 
    from {{ var('order') }}
    where lower(order_type) = 'recurring'

), order_line_items as (
    select * 
    from {{ var('order_line_item') }}

), customers_order_lines as (
    select 
        order_line_items.order_id,
        order_line_items.index,
        order_line_items.purchase_item_id as subscription_id,
        order_line_items.external_product_id_ecommerce,
        order_line_items.external_variant_id_ecommerce,
        orders.customer_id,
        orders.address_id,
        orders.order_created_at,
        orders.order_status,
        row_number() over (partition by order_line_items.purchase_item_id order by orders.order_created_at asc) = 1 as is_first_associated_order
    from orders
    left join order_line_items
        on order_line_items.order_id = orders.order_id

), subscriptions_orders as (
    select 
        subscriptions.*,
        customers_order_lines.order_id,
        customers_order_lines.index,
        customers_order_lines.order_created_at,
        customers_order_lines.order_status,
        customers_order_lines.is_first_associated_order
    from subscriptions
    left join customers_order_lines
        on customers_order_lines.subscription_id = subscriptions.subscription_id
)

select * 
from subscriptions_orders