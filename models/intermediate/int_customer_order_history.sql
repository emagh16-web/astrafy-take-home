with orders as (
    select
        order_id,
        customer_id,
        order_date
    from {{ ref('stg_orders') }}
),

order_history as (
    select
        current_order.order_id,
        current_order.customer_id,
        current_order.order_date,
        count(previous_order.order_id) as previous_orders_12m
    from orders as current_order
    left join orders as previous_order
        on current_order.customer_id = previous_order.customer_id
        and previous_order.order_date >= date_sub(
            current_order.order_date,
            interval {{ var('segmentation_lookback_months') }} month
        )
        and previous_order.order_date < current_order.order_date
    group by
        current_order.order_id,
        current_order.customer_id,
        current_order.order_date
)

select *
from order_history