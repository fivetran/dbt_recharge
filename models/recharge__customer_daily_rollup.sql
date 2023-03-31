with base as (
    select *
    from {{ ref('int_recharge__customer_daily_rollup') }}

), transactions as (
    select *
    from {{ ref('recharge__balance_transactions') }}

), aggs as (
    select
        base.customer_id,
        base.date_day,
        base.date_week,
        base.date_month,
        base.date_year,
        
        count(transactions.order_id) as no_of_orders,
        count(case when transactions.order_type = 'RECURRING' then 1 else null end) as subscription_orders,
        count(case when transactions.order_type = 'CHECKOUT' then 1 else null end) as one_time_orders,
        coalesce(sum(transactions.total_price), 0) as total_charges,

        {% set cols = ['total_discounts', 'total_tax', 'total_price', 'total_refunds', 'order_value', 'order_item_quantity'] %}
        {% for col_name in cols %}
            sum(case when transactions.order_status not in ('ERROR', 'SKIPPED', 'QUEUED') 
                then transactions.{{col_name}} else 0 end) 
                as {{col_name}}_realized
            {{ ',' if not loop.last -}}
        {% endfor %}

    from base
    left join transactions
        on cast({{ dbt.date_trunc('day','transactions.created_at') }} as date) = base.date_day
        and transactions.customer_id = base.customer_id

    {{ dbt_utils.group_by(5) }}
)

select * from aggs