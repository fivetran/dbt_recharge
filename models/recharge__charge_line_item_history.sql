with charges as (
    select *
    from {{ ref('stg_recharge__charge') }}

), charge_line_items as (
    select
        source_relation,
        charge_id,
        index,
        cast(total_price as {{ dbt.type_float() }}) as amount,
        title,
        'charge line' as line_item_type
    from {{ ref('stg_recharge__charge_line_item') }}

), discounts as (
    select
        source_relation,
        charge_id,
        0 as index,
        cast(total_discounts as {{ dbt.type_float() }}) as amount,
        'total discounts' as title,
        'discount' as line_item_type
    from charges -- have to extract discounts from charges table since not available on the line item level
    where total_discounts > 0

), charge_shipping_lines as (
    select
        source_relation,
        charge_id,
        index,
        cast(price as {{ dbt.type_float() }}) as amount,
        title,
        'shipping' as line_item_type
    from {{ ref('stg_recharge__charge_shipping_line') }}

), charge_tax_lines as (
    {% if var('recharge__charge_tax_line_enabled', true) %}
        select
            source_relation,
            charge_id,
            index,
            cast(price as {{ dbt.type_float() }}) as amount,
            title,
            'tax' as line_item_type
        from {{ ref('stg_recharge__charge_tax_line') }} -- use this if possible since it is individual tax items
    {% else %}
        select
            source_relation,
            charge_id,
            index,
            cast(tax_due as {{ dbt.type_float() }}) as amount,
            'total tax' as title,
            'tax' as line_item_type
        from {{ ref('stg_recharge__charge_line_item') }} -- use this secodary since it is total tax per charge line item
        where tax_due is not null
    {% endif %}

), refunds as (
    select
        source_relation,
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
    from discounts

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
        unioned.source_relation,
        unioned.charge_id,
        row_number() over(partition by unioned.charge_id{{ recharge.partition_by_source_relation(alias='unioned') }}
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
        and charges.source_relation = unioned.source_relation
)

select *
from joined