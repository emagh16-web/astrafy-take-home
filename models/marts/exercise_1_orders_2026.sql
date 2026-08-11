select
    count(*) as number_of_orders_2026
    from  {{ref('stg_orders')}}
    where extract(year from order_date) = 2026