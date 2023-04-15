with charges as (
    select *
    from {{ var('charge') }}

), charge_line_items as (
    select 
        charge_id,
        index,
        price as amount,
        title,
        'charge line' as line_item_type
    from {{ var('charge_line_item') }}

), discounts as (
    select *
    from {{ var('discount') }}

), charge_discount_codes as (
    select *
    from {{ var('charge_discount_code') }}

), discounts_enriched as (
    select
        charge_discount_codes.charge_id,
        charge_discount_codes.index,
        charge_discount_codes.amount,
        discounts.discount_code as title,
        'discount' as line_item_type
    from charge_discount_codes
    left join discounts
        using(discount_id)

), charge_shipping_lines as (
    select 
        charge_id,
        index,
        price as amount,
        title,
        'shipping' as line_item_type
    from {{ var('charge_shipping_line') }}

), charge_tax_lines as (
    {% if var('recharge__charge_tax_line_enabled', true) %}
        select 
            charge_id,
            index,
            price as amount,
            title,
            'tax' as line_item_type
        from {{ source('recharge','charge_tax_line') }}
    {% else %} 
        select
            charge_id,
            0 as index,
            total_tax as amount,
            'total tax' as title,
            'tax' as line_item_type
        from charges
        where total_tax > 0

    {% endif %}

), refunds as (
    select
        charge_id,
        0 as index,
        total_refunds as amount,
        'total refunds' as title,
        'refund' as line_item_type
    from charges -- have to extract refunds from charges table since a refund line item table is not available
    where total_refunds > 0

), unioned as (

    select *
    from charge_line_items

    union all
    select *
    from discounts_enriched

    union all
    select *
    from charge_shipping_lines

    union all
    select *
    from charge_tax_lines
    
    union all
    select *
    from refunds

), joined as (
    select
        unioned.charge_id,
        unioned.index,
        charges.created_at as charge_created_at,
        charges.customer_id,
        charges.address_id,
        unioned.amount,
        unioned.title,
        unioned.line_item_type

    from unioned
    left join charges
        using(charge_id)

)

select *
from joined