with transactions as (
    select *
    from {{ ref('recharge__balance_transactions') }}

{# ), calendar as (
    select *
    from {{ ref('int_recharge__calendar_spine') }} #}

{# ), customers as (
    select distinct customer_id
    from transactions

), customers_dates as (
    select 
        customers.customer_id,
        calendar.date_day
    from calendar, customers #}

), aggs as (
    select
        transactions.customer_id,
        cast({{ dbt.date_trunc('day', 'transactions.created_at') }} as date) as date_day,
        cast({{ dbt.date_trunc('week', 'transactions.created_at') }} as date) as date_week,
        cast({{ dbt.date_trunc('month', 'transactions.created_at') }} as date) as date_month,
        cast({{ dbt.date_trunc('year', 'transactions.created_at') }} as date) as date_year,

        {# calendar.date_day,
        cast({{ dbt.date_trunc('day', 'calendar.date_day') }} as date) as date_day,
        cast({{ dbt.date_trunc('week', 'calendar.date_day') }} as date) as date_week,
        cast({{ dbt.date_trunc('month', 'calendar.date_day') }} as date) as date_month,
        cast({{ dbt.date_trunc('year', 'calendar.date_day') }} as date) as date_year, #}
        
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

    from transactions

    {# from calendar
    left join transactions
        on cast({{ dbt.date_trunc('day','transactions.created_at') }} as date) = calendar.date_day #}

    {{ dbt_utils.group_by(5) }}
)

select * from aggs