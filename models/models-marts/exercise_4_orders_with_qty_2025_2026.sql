with orders as (

    select
        order_date,
        customer_id,
        order_id,
        net_sales
    from {{ ref('stg_orders') }}
    where extract(year from order_date) in (2025, 2026)

),

order_products as (

    select
        order_id,
        qty_product
    from {{ ref('int_order_product_metrics') }}

)

select
    orders.order_date,
    orders.customer_id,
    orders.order_id,
    orders.net_sales,
    order_products.qty_product
from orders
left join order_products
    on orders.order_id = order_products.order_id