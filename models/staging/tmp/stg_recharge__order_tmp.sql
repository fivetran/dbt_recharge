
select *
from
{{ var('orders') if var('recharge__using_orders', recharge.recharge_does_table_exist('orders')) else var('order') }}