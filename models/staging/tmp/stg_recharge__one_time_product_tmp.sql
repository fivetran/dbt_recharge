{{ config(enabled=var('recharge__one_time_product_enabled', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='recharge_sources',
        single_source_name='recharge',
        single_table_name='one_time_product'
    )
}}