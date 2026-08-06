with source as (

    select *
    from {{ source('raw', 'sales') }}

),

renamed as (

    select
        parse_date('%Y-%m-%d', date_date) as order_date,
        customer_id,
        order_id,
        products_id as product_id,
        safe_cast(replace(net_sales, ',', '.') as numeric) as net_sales,
        qty
    from source

)

select *
from renamed