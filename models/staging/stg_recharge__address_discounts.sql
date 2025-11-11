
with base as (

    select *
    from {{ ref('stg_recharge__address_discounts_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__address_discounts_tmp')),
                staging_columns = get_address_discounts_columns()
            )
        }}
        {{ recharge.apply_source_relation() }}
    from base
),

final as (

    select
        source_relation,
        id as discount_id,
        address_id,
        index

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final