with transactions as (
    select *
    from {{ ref('recharge__balance_transactions') }}

), calendar as (
    select *
    from {{ ref('int_recharge__calendar_spine') }}

), aggs as (
    select
        transactions.customer_id,
        calendar.date_day,

        {{ dbt.date_trunc('week', 'transactions.created_at') }} as date_week,
        {{ dbt.date_trunc('month', 'transactions.created_at') }} as date_month,
        {{ dbt.date_trunc('year', 'transactions.created_at') }} as date_year,
        
        count(transactions.order_id) as no_of_orders,
        count(case when transactions.order_type = 'RECURRING' then 1 else null end) as subscription_orders,
        count(case when transactions.order_type = 'CHECKOUT' then 1 else null end) as one_time_orders,
        coalesce(sum(transactions.total_price), 0) as total_charges,

        {% set cols = ['total_price', 'total_refunds', 'total_discounts', 'total_tax', 'order_value', 'order_item_quantity'] %}
        {% for col in cols %}
            sum(case when transactions.order_status not in ('ERROR', 'SKIPPED', 'QUEUED') 
                then transactions.{{col}} else 0 end) as {{col}}
            {{ ',' if not loop.last -}}
        {% endfor %}

    from calendar
    left join transactions
        on cast({{ dbt.date_trunc('day','transactions.created_at') }} as date) = calendar.date_day

    {{ dbt_utils.group_by(5) }}

), customers as (
    select *
    from {{ ref('int_recharge__customer_details') }}

), joined as (
    select
        aggs.*,
        customers.created_at as customer_created_at,
        customers.is_currently_subscribed,
        customers.is_new_customer

    from aggs
    left join customers
        on customers.customer_id = aggs.customer_id
)

select * from aggs