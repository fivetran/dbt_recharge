with customers as (
    select *
    from {{ ref('int_recharge__customer_details') }} 

)

select
    customers.*,

    case when active_subscriptions > 0 
        then true else false end as is_currently_subscribed,
    case when {{ dbt.datediff("created_at", dbt.current_timestamp_backcompat(), "day") }} <= 30
        then true else false end as is_new_customer,
    {{ dbt_utils.safe_divide( dbt.datediff("created_at", dbt.current_timestamp_backcompat(), "day") , 30) }}
        as active_months,

    {% set agged_cols = ['orders', 'amount_ordered', 'one_time_purchases', 'amount_charged', 'amount_discounted', 'amount_taxed', 'net_spend'] %}
    {% for col in agged_cols %}
        {{- dbt_utils.safe_divide('total_' ~ col, 'active_months') }} as avg_{{col}}_per_month -- calculates average over no. active mos
        {{ ',' if not loop.last -}}
    {% endfor %}

from customers