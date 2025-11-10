-- depends_on: {{ ref('stg_recharge__charge_tmp') }}
with spine as (

    {# Calculates first and last dates if at least one is not manually set #}
    {% if execute and flags.WHICH in ('run', 'build') %}
        {% if not var('recharge_first_date', None) or not var('recharge_last_date', None) %}
            {% set date_query %}
                select
                    cast(min(created_at) as {{ dbt.type_timestamp() }}) as min_date,
                    cast(max(created_at) as {{ dbt.type_timestamp() }}) as max_date
                from {{ ref('stg_recharge__charge_tmp') }}
            {% endset %}
        {% endif %}

    {# If only compiling, creates range going back 1 year #}
    {% else %}
        {%- set date_query %}
            select
                cast({{ dbt.dateadd("month", -1, "current_date") }} as dbt.type_timestamp()) as min_date,
                cast("current_date" as dbt.type_timestamp()) as min_date,
        {% endset -%}
    {% endif %}
    
    {% set calc_first_date = run_query(date_query).columns[0][0]|string %}
    {% set calc_last_date = run_query(date_query).columns[1][0]|string %}
    
    {# Prioritizes variables over calculated dates #}
    {% set first_date = var('recharge_first_date', calc_first_date)|string %}
    {% set last_date = var('recharge_last_date', calc_last_date)|string %}

{{ dbt_utils.date_spine(
    datepart = "day",
    start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
    end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
    )
}}
)

select *
from spine
