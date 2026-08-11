view: order_product_metrics {
  sql_table_name: `astrafy-take-home.dbt_emagh16web.exercise_4_orders_with_qty_2025_2026` ;;

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
    label: "Order ID"
    description: "Unique identifier of the order. This is a technical join key and is hidden from business users."
    hidden: yes
  }

  dimension: qty_product {
    type: number
    sql: ${TABLE}.qty_product ;;
    label: "Product Quantity"
    description: "Total quantity of products included in a single order."
    group_label: "Product Metrics"
    synonyms: ["items per order", "units per order", "basket quantity"]
  }

  measure: total_product_quantity {
    type: sum
    sql: ${qty_product} ;;
    label: "Products Sold"
    description: "Total quantity of product units sold across all selected orders."
    group_label: "Product Metrics"
    synonyms: ["units sold", "items sold", "product units"]
    drill_fields: [qty_product]
  }

  measure: average_products_per_order {
    type: average
    sql: ${qty_product} ;;
    label: "Average Products per Order"
    description: "Average number of product units included in each order."
    group_label: "Product Metrics"
    synonyms: ["average basket size", "average items per order", "items per basket"]
    value_format_name: decimal_2
  }
}
