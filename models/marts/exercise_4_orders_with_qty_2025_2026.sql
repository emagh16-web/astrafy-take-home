{{
    config(
        materialized='table',
        partition_by={
            "field": "order_date",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by=["customer_id"]
    )
}}

with orders as (
    select
        order_date,
        customer_id,
        order_id,
        net_sales
    from {{ ref('stg_orders') }}
    where extract(year from order_date) in (
        {{ var('previous_year') }},
        {{ var('target_year') }}
    )
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