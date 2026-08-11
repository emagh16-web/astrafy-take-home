view: order_product_metrics {
  sql_table_name: `astrafy-take-home.dbt_emagh16web.exercise_4_orders_with_qty_2025_2026` ;;

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
    label: "Order ID"
    description: "Unique identifier of the order."
    hidden: yes
  }

  dimension: qty_product {
    type: number
    sql: ${TABLE}.qty_product ;;
    label: "Product Quantity"
    description: "Total quantity of products included in the order."
  }

  measure: total_product_quantity {
    type: sum
    sql: ${qty_product} ;;
    label: "Products Sold"
    description: "Total quantity of products sold across the selected orders."
    drill_fields: [order_id, qty_product]
  }

  measure: average_products_per_order {
    type: average
    sql: ${qty_product} ;;
    label: "Average Products per Order"
    description: "Average quantity of products contained in an order."
    value_format_name: decimal_2
  }
}
