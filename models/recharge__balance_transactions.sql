with orders as (
    select *
    from {{ var('order') }}

), order_line_items as (
    select 
        order_id,
        sum(quantity) as order_item_quantity,
        sum(price) as order_value
    from {{ var('order_line_item') }}
    group by 1

), charges as ( --each charge can have multiple orders associated with it
    select *
    from {{ var('charge') }}

), charge_shipping_lines as (
    select 
        charge_id,
        sum(price) as total_shipping
    from {{ var('charge_shipping_line') }}
    group by 1

), charges_enriched as (
    select
        charges.*,
        charge_shipping_lines.total_shipping

    from charges
    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id

), joined as (
    select 
        orders.*,
        -- recognized_total (calculated total based on prepaid subscriptions)
        charges_enriched.processor_name,
        charges_enriched.shipments_count,
        charges_enriched.tags,

        -- when several prepaid orders are generated from a single charge, we only want to add charge aggregates on the first instance.
        {% set charge_agg_cols = ['subtotal_price', 'tax_lines', 'total_discounts', 'total_refunds', 'total_tax', 'total_weight', 'total_shipping'] %}
        {% for col in charge_agg_cols %}
            case when orders.order_type = 'RECURRING' and orders.is_prepaid = true 
                then 0 else coalesce(charges_enriched.{{ col }}, 0)
                end as {{ col }} ,
        {% endfor %}

        order_line_items.order_item_quantity,
        order_line_items.order_value

    from orders
    left join order_line_items
        on order_line_items.order_id = orders.order_id
    left join charges_enriched
        on charges_enriched.charge_id = orders.charge_id
)

select * from joined