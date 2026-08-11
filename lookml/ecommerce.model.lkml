connection: "bigquery"

include: "/views/*.view.lkml"

explore: orders {
  label: "E-commerce Orders"
  description: "Business-ready order analysis for revenue, orders, customers, product quantities, and customer segmentation."
}
