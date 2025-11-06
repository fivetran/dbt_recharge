{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'recharge') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('recharge_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("recharge_database", target.database) }}' || '.'|| '{{ var("recharge_schema", "recharge") }}' as source_relation
{% endif %}

{%- endmacro %}