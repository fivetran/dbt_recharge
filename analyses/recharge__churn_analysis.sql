with customers as (
    select *
    from {{ ref('recharge__customer_details') }}

), why_churned as (
    select 
        customers.*,

        {# Definitions of churned per recharge docs #}
        case when calculated_subscriptions_active_count = 0 and has_valid_payment_method is false
            then 'passive cancellation' as churn_reason,
        case when calculated_subscriptions_active_count = 0 and has_valid_payment_method is true
            then 'active cancellation' as churn_reason,
        case when calculated_subscriptions_active_count > 0 and has_valid_payment_method is false
            then 'charge error' as churn_reason

    from customers
)

select *
from why_churned