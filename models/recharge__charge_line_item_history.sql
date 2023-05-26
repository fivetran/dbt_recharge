with charges as (
    select *
    from {{ var('charge') }}

), charge_line_items as (
    select 
        charge_id,
        index,
        cast(total_price as {{ dbt.type_float() }}) as amount,
        title,
        'charge line' as line_item_type
    from {{ var('charge_line_item') }}

), charge_discounts as (
    select *
    from {{ var('charge_discount') }}

), discounts_enriched as (
    select
        charge_discounts.charge_id,
        charge_discounts.index,
        cast(case when lower(charge_discounts.value_type) = 'percentage'
            then charge_discounts.discount_value * charges.total_line_items_price
            else charge_discounts.discount_value 
            end as {{ dbt.type_float() }}) as amount,
        charge_discounts.value_type as title,
        'discount' as line_item_type
    from charge_discounts
    left join charges
        on charges.charge_id = charge_discounts.charge_id

), charge_shipping_lines as (
    select 
        charge_id,
        index,
        cast(price as {{ dbt.type_float() }}) as amount,
        title,
        'shipping' as line_item_type
    from {{ var('charge_shipping_line') }}

), charge_tax_lines as (
    {% if var('recharge__charge_tax_line_enabled', true) %}
        select 
            charge_id,
            index,
            cast(price as {{ dbt.type_float() }}) as amount,
            title,
            'tax' as line_item_type
        from {{ var('charge_tax_line') }} -- use this if possible since it is individual tax items
    {% else %} 
        select
            charge_id,
            index,
            cast(tax_due as {{ dbt.type_float() }}) as amount,
            'total tax' as title,
            'tax' as line_item_type
        from {{ var('charge_line_item') }} -- use this secodary since it is total tax per charge line item
        where tax_due is not null
    {% endif %}

), refunds as (
    select
        charge_id,
        0 as index,
        cast(total_refunds as {{ dbt.type_float() }}) as amount,
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
        row_number() over(partition by unioned.charge_id 
            order by unioned.line_item_type, unioned.index) 
            as charge_row_num,
        unioned.index as source_index,
        charges.charge_created_at,
        charges.customer_id,
        charges.address_id,
        unioned.amount,
        unioned.title,
        unioned.line_item_type
    from unioned
    left join charges
        on charges.charge_id = unioned.charge_id
)

select *
from joined