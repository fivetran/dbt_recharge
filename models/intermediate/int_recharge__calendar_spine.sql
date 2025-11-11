-- depends_on: {{ ref('stg_recharge__charge_tmp') }}

with spine as (
    -- Get the min and max dates from stg_recharge__charge_tmp if either recharge_*_date has not been set.
    {% if execute and flags.WHICH in ('run', 'build') and (not var('recharge_first_date', None) or not var('recharge_last_date', None)) %}
        {%- set first_date_query %}
            select 
                cast(min(created_at) as date) as min_date
            from {{ ref('stg_recharge__charge_tmp') }}
        {% endset -%}
        
        {%- set last_date_query %}
            select 
                cast(max(created_at) as date) as max_date
            from {{ ref('stg_recharge__charge_tmp') }}
        {% endset -%}

    {% else %}
        {%- set first_date_query %}
            select cast({{ dbt.dateadd("month", -1, dbt.current_timestamp() ) }} as date) as min_date
        {% endset -%}

        {%- set last_date_query %}
            select cast({{ dbt.current_timestamp() }} as date) as max_date
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