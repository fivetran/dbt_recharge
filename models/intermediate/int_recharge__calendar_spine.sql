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
    {% set first_date = run_query(date_query).columns[0][0]|string %}
    {% set last_date = run_query(date_query).columns[1][0]|string %}
    
    {% else %} 
    {% set first_date = dbt.dateadd("year", "-2", "current_date") %}
    {% set last_date = dbt.current_timestamp_backcompat() %}
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