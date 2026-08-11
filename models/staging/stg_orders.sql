with source as (
    select * 
    from {{ source ('raw','orders')}}
),
renamed as (
    select 
    parse_date('%d/%m/%Y', date_date) as order_date,
    customers_id as customer_id,
    orders_id as order_id,
    safe_cast(replace(net_sales,',','.') as numeric) as net_sales
    from source
)
select *
from renamed