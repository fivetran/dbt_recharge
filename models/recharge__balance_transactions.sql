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

), charge_shipping_lines as (
    select 
        charge_id,
        sum(prices) as total_shipping
    from {{ var('charge_shipping_line') }}
    group by 1

), joined as (
    select 
        base.*,
        charges.processor_name,
        charges.shipments_count,
        charges.sub_total,
        charges.subtotal_price,
        charges.tags,
        charges.tax_lines,
        charges.total_discounts,
        charges.total_line_items_price,
        charges.total_refunds,
        charges.total_tax,
        charges.total_weight,
        charge_shipping_lines.total_shipping,
        order_line_items.order_item_quantity

    from base
    left join order_line_items
        on order_line_items.order_id = base.order_id
    left join charges
        on charges.charge_id = base.charge_id
    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = base.charge_id
)

select * from joined