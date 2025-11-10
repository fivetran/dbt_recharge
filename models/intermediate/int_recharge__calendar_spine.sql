-- depends_on: {{ ref('stg_recharge__charge_tmp') }}

with spine as (

    {% if execute and flags.WHICH in ('run', 'build') %}
        {% if is_incremental() %}
            -- For incremental runs, look back 14 days from the latest charge date.
            {%- set first_date_query %}
                select 
                    cast({{ dbt.dateadd("day", -14, "max(created_at)") }} as date)
                from {{ ref('stg_recharge__charge_tmp') }}
            {% endset -%}

        {% else %}
            -- For full-refresh runs, use either the date from var(recharge_first_date) or the min date.
            {%- set first_date_query %}
                select 
                    coalesce(
                        min(cast(created_at as date)), 
                        cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
                    ) as min_date
                from {{ ref('stg_recharge__charge_tmp') }}
            {% endset -%}
            
        {% endif %}

        -- For both cases, use var(recharge_last_date) or today as the final date.
        {%- set last_date_query %}
            select 
                coalesce(
                    cast({{ dbt.dateadd("week", 1, "current_date") }} as date),
                    current_date
                )
        {% endset -%}

    {% else %}
        -- Compile-time fallback range (1 month back to current_date).
        {%- set first_date_query %}
            select
                cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
        {% endset -%}

        {%- set last_date_query %}
            select cast("current_date" as date)
        {% endset -%}
    {% endif %}

    {%- set first_date = var('recharge_first_date', dbt_utils.get_single_value(first_date_query)) %}
    {%- set last_date = var('recharge_last_date', dbt_utils.get_single_value(last_date_query)) %}

    {{ dbt_utils.date_spine(
        datepart = "day",
        start_date = "cast('" ~ first_date ~ "' as date)",
        end_date = "cast('" ~ last_date ~ "' as date)"
    ) }}
)

select *
from spine