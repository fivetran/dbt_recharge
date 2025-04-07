{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
-- This test checks that the charge-level amounts in the prod and dev recharge__charge_line_item_history models are consistent.

with prod as (
    select
        charge_id,
        source_index,
        amount,
        title,
        line_item_type
    from {{ target.schema }}_recharge_prod.recharge__charge_line_item_history
),

dev as (

    select
        charge_id,
        source_index,
        amount,
        title,
        line_item_type
    from {{ target.schema }}_recharge_dev.recharge__charge_line_item_history
),

final as (

    select
        prod.charge_id,
        prod.title,
        prod.line_item_type,
        sum(prod.amount) as prod_amount,
        sum(dev.amount) as dev_amount
    from prod
    full outer join dev 
        on dev.charge_id = prod.charge_id
        and dev.source_index = prod.source_index
        and dev.title = prod.title
        and dev.line_item_type = prod.line_item_type
    group by 1, 2, 3
)

select *
from final
where prod_amount != dev_amount