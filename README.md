# Astrafy Take-Home Challenge

Analytics Engineering take-home challenge built with **dbt**, **Google BigQuery**, **LookML**, and **Data Studio**.

The project transforms raw e-commerce order and sales data into tested, documented, analytics-ready models following a layered dbt architecture:

**Raw → Staging → Intermediate → Marts**

The final models answer the six analytical exercises included in the challenge and provide reusable datasets for reporting, semantic modeling, dashboarding, and forecasting.

---

## Tech Stack

- Google BigQuery
- BigQuery ML
- dbt Cloud
- SQL
- Git / GitHub
- LookML
- Data Studio

---

## Project Structure

```text
models/
├── staging/
│   ├── sources.yml
│   ├── staging.yml
│   ├── stg_orders.sql
│   └── stg_sales.sql
│
├── intermediate/
│   ├── intermediate.yml
│   ├── int_order_product_metrics.sql
│   └── int_customer_order_history.sql
│
└── marts/
    ├── marts.yml
    ├── exercise_1_orders_2026.sql
    ├── exercise_2_orders_per_month_2026.sql
    ├── exercise_3_avg_products_per_order_2026.sql
    ├── exercise_4_orders_with_qty_2025_2026.sql
    ├── exercise_5_order_segmentation_2026.sql
    └── exercise_6_orders_with_segmentation_2026.sql
Architecture
Raw
The original source files are loaded into the BigQuery raw dataset.
Main source tables:

raw.orders — one row per order
raw.sales — one row per order/product line
Staging
The staging layer standardizes and cleans the raw source data.
stg_orders
Main transformations:
Parses order dates into BigQuery DATE
Standardizes column names
Converts net sales values from decimal-comma strings into NUMERIC
Creates a clean one-row-per-order dataset
stg_sales
Main transformations:
Parses sales dates
Standardizes identifiers
Converts net sales values to NUMERIC
Preserves product quantities for downstream aggregation
Intermediate
The intermediate layer contains reusable business logic used by multiple final models.
int_order_product_metrics
Aggregates product quantities to order level.
Output grain:

One row per order

Main metric:

qty_product = total quantity of products in each order.

int_customer_order_history
Calculates the number of previous orders made by each customer during the configured lookback period before every order.
The default lookback period is:

segmentation_lookback_months: 12
This model supports the customer segmentation logic used in Exercises 5 and 6.
Marts / Exercises
Exercise 1 — Orders in 2026
Calculates the total number of orders placed during 2026.
Result: 2,573 orders

Model:

exercise_1_orders_2026

Exercise 2 — Orders per Month
Calculates the number of orders for each month of 2026.
Output grain:

One row per month

Model:

exercise_2_orders_per_month_2026

Exercise 3 — Average Products per Order
Calculates the average number of products contained in an order for each month of 2026.
The model combines:

order dates from stg_orders
product quantities from int_order_product_metrics
Model:
exercise_3_avg_products_per_order_2026

Exercise 4 — Orders with Product Quantity
Creates an order-level table containing all orders from 2025 and 2026 together with total product quantity.
Output grain:

One row per order

Main columns:

order_date
customer_id
order_id
net_sales
qty_product
Model:
exercise_4_orders_with_qty_2025_2026

This model is materialized as a BigQuery table.

Exercise 5 — Customer Order Segmentation
Each order placed in 2026 is classified according to the customer's previous-order activity during the preceding 12 months.
Previous orders in prior 12 months	Segment
0	New
1–3	Returning
4+	VIP
Model:
exercise_5_order_segmentation_2026

Exercise 6 — Orders with Segmentation
Creates the final 2026 order-level dataset enriched with the customer segmentation calculated in Exercise 5.
Output grain:

One row per order

Main columns:

order_date
customer_id
order_id
net_sales
order_segmentation
Model:
exercise_6_orders_with_segmentation_2026

Variables and Reduced Hardcoding
Common business parameters are defined centrally in dbt_project.yml instead of being repeated throughout SQL models.
vars:
  target_year: 2026
  previous_year: 2025
  segmentation_lookback_months: 12
For example, instead of:
where extract(year from order_date) = 2026
the models use:
where extract(year from order_date) = {{ var('target_year') }}
This makes the project easier to maintain and adapt to future reporting periods.
BigQuery Performance Optimization
The larger final order-level models are materialized as tables and optimized using BigQuery partitioning and clustering.
Exercise 4
Partitioned by:
order_date — monthly granularity
Clustered by:
customer_id
Exercise 6
Partitioned by:
order_date — monthly granularity
Clustered by:
customer_id
Partitioning reduces the amount of data scanned for date-based queries, while clustering improves performance for customer-level filtering and analysis.
Data Quality Tests
dbt generic tests are used across staging, intermediate, and marts models.
Tests include:

not_null
unique
accepted_values
Example segmentation validation:
data_tests:
  - not_null
  - accepted_values:
      arguments:
        values: ['New', 'Returning', 'VIP']
This ensures that segmentation contains only valid business-defined categories.
Build Validation
The complete project was validated using:
dbt build
Final build result:
47 passed
0 warnings
0 errors
0 skipped
This validates the complete dependency chain from staging through intermediate models and marts.
Model Lineage
The project uses dbt source() and ref() functions to explicitly define dependencies between models.
Example flow:

raw.orders
     ↓
stg_orders
     ↓
int_customer_order_history
     ↓
exercise_5_order_segmentation_2026
     ↓
exercise_6_orders_with_segmentation_2026
Product quantity flow:
raw.sales
     ↓
stg_sales
     ↓
int_order_product_metrics
     ↓
exercise_3 / exercise_4
Using ref() allows dbt to automatically determine model execution order and generate lineage.
Assumptions
Date Granularity
The source data contains order dates but no order timestamp.
Because the exact order sequence within the same day is unavailable, two orders placed by the same customer on the same date cannot reliably be ordered chronologically.

For segmentation purposes, only orders with:

previous_order.order_date < current_order.order_date
are considered previous orders.
Therefore, another order from the same customer occurring on the same calendar date is not counted as a previous order.

Dataset Period
The supplied source data used for the implementation contains records for the periods required by the analytical exercises, including 2025 and 2026.
Running the Project
To build the complete project and execute all configured tests:
dbt build
To run models only:
dbt run
To execute all data quality tests:
dbt test
Example of running a specific model:
dbt run --select exercise_6_orders_with_segmentation_2026
Example of testing the marts layer:
dbt test --select path:models/marts
LookML Semantic Layer
The project includes a modular LookML semantic layer designed to be deployment-ready for Looker.
Structure
lookml/
├── ecommerce.model.lkml
└── views/
    ├── orders.view.lkml
    └── order_product_metrics.view.lkml
The ecommerce.model.lkml file defines the main Explore and the relationship between the business-facing views.
Explore and Joins
The primary Explore is:
E-commerce Orders

The orders view is the main Explore source and is joined to order_product_metrics using order_id.

The join is defined as a left outer one-to-one relationship so that all orders are preserved while product-level metrics can be analyzed in the same Explore.

Customer Segmentation
Customer segmentation from Part 1 is exposed directly in the semantic layer through the Customer Segment dimension.
Available segments:

New
Returning
VIP
This allows business users to filter, pivot, compare, and visualize KPIs by customer segment.
Business KPIs
The semantic layer exposes business-oriented measures including:
Revenue
Orders
Customers
Average Order Value
Products Sold
Average Products per Order
These fields are designed to support marketing and sales analysis without requiring users to understand the underlying SQL or database structure.
Conversational Analytics / GenAI Readiness
The LookML layer includes metadata intended to improve Natural Language and Conversational Analytics experiences.
This includes:

clear business-friendly field labels
detailed field descriptions
synonyms such as sales, turnover, AOV, buyers, and basket size
grouped fields using group_label
hidden technical join keys
explicit segmentation definitions
These design choices help reduce ambiguity and provide semantic context for AI-assisted querying.
Deployment Note
The model currently uses:
connection: "bigquery"
as a placeholder connection name.
When deployed to a real Looker instance, this value should be replaced with the actual Looker database connection name configured for the BigQuery environment.

The underlying views reference the analytics-ready BigQuery tables created in Part 1.

Bonus: Revenue Forecast
A 7-day sales revenue forecast was implemented using BigQuery ML with an ARIMA_PLUS time-series model.
The model is trained on historical daily revenue and produces:

forecast revenue
lower prediction interval
upper prediction interval
The forecast output is stored in:
revenue_forecast_7d

The forecast is visualized on the Revenue Forecast page of the Data Studio dashboard.

Dashboard
Data Studio dashboard:
View the E-commerce Marketing Dashboard (https://datastudio.google.com/reporting/a594d255-b6a2-415f-a791-b5fd4204bbe8)

The dashboard includes:

Executive Overview
Customer & Product Analysis
7-Day Revenue Forecast
The dashboard has been shared with:
founders@astrafy.io
bi@astrafy.io
Repository
This repository contains the complete dbt and LookML implementation for the Astrafy Analytics / Insights Engineering take-home challenge.





