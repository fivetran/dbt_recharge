with base as (
    select *
    from {{ var('order') }}

), order_line_items as (
    select 
        order_id,
        sum(quantity) as order_item_quantity
    from {{ var('order_line_item') }}
    group by 1

), charges as (
    select *
    from {{ var('charge') }}

{# ), products as (
    select *
    from {{ var('plan') }} #}

), joined as (
    select 
        order.*,
        charges.shipment_count,
        charges.sub_total,
        charges.subtotal_price,
        charges.tags,
        charges.total_discounts,
        charges.total_line_items_price,
        charges.total_refunds,
        charges.total_tax,
        charges.total_weight,
        order_line_items.order_item_quantity

    from base
    left join order_line_items
        on order_line_items.order_id = base.order_id
    left join charges
        on charges.charge_id = base.charge_id
    {# left join products
        on products.product_id = order_line_items.procuct_id #}
)



select * from joined