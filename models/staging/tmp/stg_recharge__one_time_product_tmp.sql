{{ config(enabled=var('recharge__one_time_product_enabled', True)) }}

{{
    recharge.recharge_union_connections(
        connection_dictionary='recharge_sources',
        single_source_name='recharge',
        single_table_name='one_time_product'
    )
}}