CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.customers AS
SELECT DISTINCT
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    LOWER(TRIM(email)) AS email,
    TRIM(city) AS city,
    signup_date
FROM retail_store.customers
WHERE customer_id IS NOT NULL;

CREATE TABLE staging.products AS
SELECT DISTINCT
     product_id,
     TRIM(product_name) AS product_name,
     TRIM(category) AS category,
     price,
     stock_quantity
FROM retail_store.products
WHERE product_id IS NOT NULL;

CREATE TABLE staging.orders AS
SELECT DISTINCT
     order_id,
     customer_id,
     order_date,
     TRIM(status) AS status,
     total_amount
FROM retail_store.orders
WHERE order_id IS NOT NULL;

CREATE TABLE staging.payments AS
SELECT DISTINCT
     payment_id,
     order_id,
     payment_date,
     amount,
     TRIM(method) AS method
FROM retail_store.payments
WHERE payment_id IS NOT NULL;

CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.dim_customers AS
SELECT * FROM staging.customers;

CREATE TABLE warehouse.dim_products AS
SELECT * FROM staging.products;

CREATE TABLE warehouse.fact_orders AS
SELECT * FROM staging.orders;

CREATE TABLE warehouse.fact_payments AS
SELECT * FROM staging.payments;

-- Top 5 customers by total spend
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent
FROM warehouse.fact_orders o
JOIN warehouse.dim_customers c ON o.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- Monthly revenue trend
SELECT DATE_TRUNC('month', order_date) AS month, SUM(total_amount) AS monthly_revenue
FROM warehouse.fact_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Monthly revenue with previous month comparison (LAG)
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS monthly_revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS previous_month_revenue
FROM warehouse.fact_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Customers who spent above average (CTE)
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spent
    FROM warehouse.fact_orders o
    JOIN warehouse.dim_customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals);