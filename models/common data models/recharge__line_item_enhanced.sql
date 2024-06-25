with charge_line_items as (

    select * 
    from {{ var('charge_line_item')}}

), addresses as (

    select * 
    from {{ var('address') }}

), charges as (

    select * 
    from {{ var('charge') }}

), charge_shipping_lines as (

    select
        charge_id,
        sum(price) as total_shipping
    from {{ var('charge_shipping_line') }}
    group by 1

{% if var('recharge__using_checkout', false) %}
), checkouts as (

    select *
    from {{ var('checkout') }}

{% endif %}

), subscriptions as (

    select *
    from {{ var('subscription_history') }} 
    where is_most_recent_record

), enhanced as (
    select
        charge_line_items.charge_id as header_id,
        charge_line_items.index as line_item_id,
        row_number() over (partition by charge_line_items.charge_id
            order by charge_line_items.index) as line_item_index,

        -- header level items
        charges.created_at,
        charges.charge_status as header_status,
        charges.total_discounts as discount_amount,
        charges.total_refunds as refund_amount,
        charge_shipping_lines.total_shipping as fee_amount,
        addresses.payment_method_id,
        charges.external_transaction_id_payment_processor as payment_id,
        charges.payment_processor as payment_method,
        charges.processed_at as payment_at,
        charges.type as transaction_type,  -- possible values: checkout, recurring

        {% if var('recharge__using_checkout', false) %}
        checkouts.currency,
        {% endif %}

        charge_lines.purchase_item_type as billing_type, -- possible values: subscription, onetime
        charge_line_items.external_product_id_ecommerce as product_id,
        charge_line_items.title as product_name,
        -- products.category as product_type,
        cast(null as {{ dbt.type_string() }}) as product_type,
        charge_line_items.quantity,
        charge_line_items.unit_price as unit_amount,
        charge_line_items.tax_due as tax_amount,
        charge_line_items.total_price as total_amount,
        subscriptions.subscription_id, -- on charge_line_items.purchase_item_id = subscriptions.subscription_id
        subscriptions.subscription_created_at as subscription_period_started_at,
        subscriptions.subscription_cancelled_at as subscription_period_ended_at,
        subscriptions.subscription_status,
        'customer' as customer_level,
        charges.customer_id as customer_id,
        {{ dbt.concat(["charges.first_name", "' '", "charges.last_name"]) }} as customer_name,
        charges.email as customer_email,
        addresses.company as customer_company,
        addresses.city as customer_city,
        addresses.country as customer_country

    from charge_line_items

    left join charges
        on charges.charge_id = charge_line_items.charge_id

    left join addresses
        on addresses.address_id = charges.address_id

    {% if var('recharge__using_checkout', false) %}
    left join checkouts
        on checkouts.charge_id = charges.charge_id
    {% endif %}

    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id

    left join subscriptions
        on subscriptions.subscription_id = charge_line_items.purchase_item_id

), final as (

    select 
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        created_at,
        header_status,
        billing_type,
        currency,
        product_id,
        product_name,
        product_type,
        transaction_type,
        quantity,
        unit_amount,
        cast(null as {{ dbt.type_float() }}) as discount_amount,
        cast(null as {{ dbt.type_float() }}) as refund_amount,
        cast(null as {{ dbt.type_float() }}) as fee_amount,
        tax_amount,
        total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced

    union all

    -- Refund information is only reliable at the charge header. Therefore the below operation creates a new line to track the refund values.
    select
        header_id,
        cast(null as {{ dbt.type_string() }}) as line_item_id,
        cast(0 as {{ dbt.type_int() }}) as line_item_index,
        'header' as record_type,
        created_at,
        header_status,
        billing_type,
        currency,
        transaction_type,
        cast(null as {{ dbt.type_string() }}) as product_id,
        cast(null as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_float() }}) as quantity,
        cast(null as {{ dbt.type_float() }}) as unit_amount,
        cast(null as {{ dbt.type_float() }}) as tax_amount,
        cast(null as {{ dbt.type_float() }}) as total_amount,
        discount_amount,
        fee_amount,
        refund_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_string() }}) as subscription_id,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_started_at,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_ended_at,
        cast(null as {{ dbt.type_string() }}) as subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced
    where line_item_index = 1
)

select *
from enhanced