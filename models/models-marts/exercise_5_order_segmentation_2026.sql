select
    order_id,
    customer_id,
    order_date,
    previous_orders_12m,

    case
        when previous_orders_12m = 0 then 'New'
        when previous_orders_12m between 1 and 3 then 'Returning'
        when previous_orders_12m >= 4 then 'VIP'
    end as order_segmentation

from {{ ref('int_customer_order_history') }}

where extract(year from order_date) = 2026