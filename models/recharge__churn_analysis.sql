with subscription_overview as (
    select *
    from {{ ref('recharge__subscription_overview') }}

), customers as (
    select *
    from {{ ref('recharge__customer_details') }}
)
