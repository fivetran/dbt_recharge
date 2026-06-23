{{ config(enabled=var('recharge__charge_tax_line_enabled', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='recharge_sources',
        single_source_name='recharge',
        single_table_name='charge_tax_line'
    )
}}