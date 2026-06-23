{{ config(enabled=var('recharge__checkout_enabled', false)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='recharge_sources',
        single_source_name='recharge',
        single_table_name='checkout'
    )
}}