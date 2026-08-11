with orders as (

    select
        order_id,
        order_date
    from {{ ref('stg_orders') }}
    where extract(year from order_date) = 2026

),

order_products as (

    select
        order_id,
        qty_product
    from {{ ref('int_order_product_metrics') }}

),

joined as (

    select
        orders.order_date,
        orders.order_id,
        order_products.qty_product
    from orders
    left join order_products
        on orders.order_id = order_products.order_id

)

select
    date_trunc(order_date, month) as order_month,
    avg(qty_product) as avg_products_per_order
from joined
group by order_month
order by order_month