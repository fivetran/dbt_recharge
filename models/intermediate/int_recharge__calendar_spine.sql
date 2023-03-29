-- depends_on: {{ ref('stg_recharge__charge') }}
-- Line 1 is necessary for spine CTE to run. 
with spine as (
    {% if execute %}
    {% set date_query %}
        select  
            cast(min(created_at) as {{ dbt.type_timestamp() }}) as min_date,
            cast(max(created_at) as {{ dbt.type_timestamp() }}) as max_date 
        from {{ var('charge') }}
        {% endset %}
    {% set calc_first_date = run_query(date_query).columns[0][0]|string %}
    {% set calc_last_date = run_query(date_query).columns[1][0]|string %}
    
    {% set first_date = var('recharge_first_date', calc_first_date)|string %}
    {% set last_date = var('recharge_last_date', calc_last_date)|string %}

    {% else %} 
    {% set default_first_date = dbt.dateadd("year", "-2", "current_date") %}
    {% set default_last_date = dbt.current_timestamp_backcompat() %}

    {% set first_date = var('recharge_first_date', default_first_date)|string %}
    {% set last_date = var('recharge_last_date', default_last_date)|string %}
    {% endif %}

{{ dbt_utils.date_spine(
    datepart = "day",
    start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
    end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
    )
}}
)

select *
from spine