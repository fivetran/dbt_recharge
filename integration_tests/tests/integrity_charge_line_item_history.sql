{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
-- This test checks that the number of charge ids in the staging table and the final table are the same.

with stg_charge_count as (
    select count(distinct charge_id) as stg_count
    from {{ target.schema }}_recharge_dev.stg_recharge__charge
),

charge_line_item_charge_count as (
    select count(distinct charge_id) as final_count
    from {{ target.schema }}_recharge_dev.recharge__charge_line_item_history
),

final as (
    select *
    from stg_charge_count
    join charge_line_item_charge_count
        on stg_count != final_count
)

select *
from final