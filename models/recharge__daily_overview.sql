with charges as (
    select *
    from {{ var('charge') }}

), calendar as (
    select *
    from {{ ref('int_recharge__calendar_spine') }}

), aggs as (
    select
        calendar.date_day,
        coalesce(sum(total_price), 0) as total_price
    from calendar
    left join charges
        on cast({{ dbt.date_trunc('day','charges.created_at') }} as date) = calendar.date_day
    group by 1
)

select * from aggs