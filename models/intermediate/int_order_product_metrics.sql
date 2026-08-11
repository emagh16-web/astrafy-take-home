with sales as (

    select *
    from {{ ref('stg_sales') }}

),

order_metrics as (

    select
        order_id,
        sum(qty) as qty_product
    from sales
    group by order_id

)

select *
from order_metrics