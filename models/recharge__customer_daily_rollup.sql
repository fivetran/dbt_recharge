with base as (
    select *
    from {{ ref('int_recharge__customer_daily_rollup') }}

), billing as (
    select *
    from {{ ref('recharge__billing_history') }}

), customers as (
    select 
        customer_id,
        created_at
    from {{ ref('recharge__customer_details') }}

), aggs as (
    select
        base.customer_id,
        base.date_day,
        base.date_week,
        base.date_month,
        base.date_year,

        count(billing.order_id) as no_of_orders,
        count(case when lower(billing.order_type) = 'recurring' then 1 else null end) as subscription_orders,
        count(case when lower(billing.order_type) = 'checkout' then 1 else null end) as one_time_orders,
        coalesce(sum(billing.total_price), 0) as total_charges,

        {% set cols = ['total_discounts', 'total_tax', 'total_price', 'total_refunds', 'order_line_item_total', 'order_item_quantity'] %}
        {% for col_name in cols %}
            round(sum(case when lower(billing.order_status) = 'success'
                then billing.{{col_name}} else 0 end), 2)
                as {{col_name}}_realized
            {{ ',' if not loop.last -}}
        {% endfor %}

    from base
    left join billing
        on cast({{ dbt.date_trunc('day','billing.created_at') }} as date) = base.date_day
        and billing.customer_id = base.customer_id

    {{ dbt_utils.group_by(5) }}

), aggs_running as (
    select
        *,
        {% for col_name in cols %}
            round(sum({{col_name}}_realized) over(partition by customer_id order by date_day asc), 2)
                as {{col_name}}_running_total
            {{ ',' if not loop.last -}}
        {% endfor %}
    from aggs

), active_months as (
    select
        aggs_running.*,
        round({{ dbt.datediff("customers.created_at", "aggs_running.date_day", "day") }} / 30, 2)
            as active_months_to_date

    from aggs_running
    left join customers
        on customers.customer_id = aggs_running.customer_id

)

select * 
from active_months