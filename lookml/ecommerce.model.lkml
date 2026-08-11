connection: "bigquery"

include: "/views/*.view.lkml"

explore: orders {
  label: "E-commerce Orders"
  description: "Business-ready order analysis for revenue, orders, customers, product quantities, and customer segmentation."

  join: order_product_metrics {
    type: left_outer
    sql_on: ${orders.order_id} = ${order_product_metrics.order_id} ;;
    relationship: one_to_one
  }
}
