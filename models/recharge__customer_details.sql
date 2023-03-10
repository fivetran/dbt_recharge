with customers as (
    select *
    from {{ ref('int_recharge__customer_details') }} 

)

select
    customer_id,
    customer_hash,
    shopify_customer_id,
    email,
    customer_full_name,
    created_at,
    customer_status,
    first_charge_processed_at,
    is_new_customer,
    active_subscriptions,
    total_subscriptions,
    total_orders,
    total_one_time_purchases,
    total_charges,
    total_discounts,
    {# total_amount_paid, #}
    avg_order_value,
    units_per_transaction

from customers