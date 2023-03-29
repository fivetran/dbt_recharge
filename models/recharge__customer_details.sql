with customers as (
    select *
    from {{ ref('int_recharge__customer_details') }} 
)

select
    customer_id,
    created_at,
    first_charge_processed_at,
    is_new_customer,
    shopify_customer_id,
    email,
    customer_full_name,
    customer_hash,

    active_subscriptions,
    total_subscriptions,
    avg_order_value,
    avg_item_quantity_per_order,

    {% set agged_cols = ['orders', 'amount_ordered', 'one_time_purchases', 'amount_charged', 'amount_discounted', 'amount_taxed', 'net_spend'] %}
    {% for col in agged_cols %}
        total_{{col}},
        {{- dbt_utils.safe_divide('total_' ~ col, 'active_months') }} as avg_{{col}}_per_month -- calculates average over no. active mos
        {{ ',' if not loop.last -}}
    {% endfor %}


from customers