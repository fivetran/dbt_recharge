with customers as (
    select *
    from {{ ref('int_recharge__customer_details') }} 
)

select
    customer_id,
    created_at,
    first_charge_processed_at,
    is_new_customer,
    customer_hash,
    shopify_customer_id,
    email,
    customer_full_name,
    customer_status,

    active_subscriptions,
    total_subscriptions,
    avg_order_value,
    avg_item_quantity_per_order,
    total_orders,
    {{ dbt_utils.safe_divide('total_orders', 'active_months') }} as avg_orders_per_month,
    total_amount_ordered,
    {{ dbt_utils.safe_divide('total_amount_ordered', 'active_months') }} as avg_amount_ordered_per_month,
    total_one_time_purchases,
    {{ dbt_utils.safe_divide('total_one_time_purchases', 'active_months') }} as avg_one_time_purchases_per_month,
    total_amount_charged,
    {{ dbt_utils.safe_divide('total_amount_charged', 'active_months') }} as avg_amount_charged_per_month,
    total_amount_discounted,
    {{ dbt_utils.safe_divide('total_amount_discounted', 'active_months') }} as avg_amount_discounted_per_month,
    total_amount_taxed,
    {{ dbt_utils.safe_divide('total_amount_taxed', 'active_months') }} as avg_amount_taxed_per_month,
    total_net_spend,
    {{ dbt_utils.safe_divide('total_net_spend', 'active_months') }} as avg_net_spend_per_month

from customers