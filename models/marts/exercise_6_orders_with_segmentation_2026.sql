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
    where extract(year from order_date) = {{ var('target_year') }}

),

segmentation as (

    select
        order_id,
        order_segmentation
    from {{ ref('exercise_5_order_segmentation_2026') }}

)

select
    orders.order_date,
    orders.customer_id,
    orders.order_id,
    orders.net_sales,
    segmentation.order_segmentation
from orders
left join segmentation
    on orders.order_id = segmentation.order_id