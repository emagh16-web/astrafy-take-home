select
    date_trunc(order_date, month) as order_month,
    count(*) as number_of_orders
from {{ ref('stg_orders') }}
where extract(year from order_date) = {{ var('target_year') }}
group by order_month
order by order_month