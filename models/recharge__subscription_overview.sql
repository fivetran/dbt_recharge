with subscriptions as (

    select * 
    from {{ var('subscription_history') }}
    where is_most_recent_record

), charges as (
    select * 
    from {{ var('charge') }}
    where lower(charge_type) = 'recurring'

), charge_line_items as (
    select * 
    from {{ var('charge_line_item') }}

), customers_charge_lines as (
    select 
        charge_line_items.charge_id,
        charge_line_items.shopify_product_id,
        charge_line_items.shopify_variant_id,
        charges.customer_id,
        charges.address_id,
        charges.charge_status
    from charge_line_items
    left join charges
        using(charge_id)

), subscriptions_charges as (
    select 
        subscriptions.subscription_id,
        count(case when lower(customers_charge_lines.charge_status) = 'success' 
            then 1 else null
            end) as count_successful_charges,
        count(case when lower(customers_charge_lines.charge_status) = 'queued' 
            then 1 else null
            end) as count_queued_charges
    from subscriptions
    left join customers_charge_lines
        on customers_charge_lines.customer_id = subscriptions.customer_id
        and customers_charge_lines.address_id = subscriptions.address_id
        and customers_charge_lines.shopify_product_id = subscriptions.shopify_product_id
    group by 1

), subscriptions_enriched as (
    select
        subscriptions.*,
        subscriptions_charges.count_successful_charges,
        subscriptions_charges.count_queued_charges,
        case when next_charge_scheduled_at is null then null
            when expire_after_specific_number_of_charges - count_successful_charges < 0 then null
            else expire_after_specific_number_of_charges - count_successful_charges
            end as charges_until_expiration,
        case when lower(order_interval_unit) = 'month' then charge_interval_frequency * 30
            when lower(order_interval_unit) = 'week' then charge_interval_frequency * 7
            else charge_interval_frequency 
            end as charge_interval_frequency_days
    from subscriptions
    left join subscriptions_charges
        using(subscription_id)
)

select * 
from subscriptions_enriched