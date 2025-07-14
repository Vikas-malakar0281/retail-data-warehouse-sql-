-- File: gold_views_enriched.sql
-- Purpose: Gold Layer Views based on enriched Silver Layer tables

-- ===============================
-- FACT VIEW: Sales Summary
-- ===============================
CREATE OR ALTER VIEW gold.vw_fact_sales_summary AS
SELECT
    s.dwh_sale_by_year     AS year,
    s.dwh_sale_by_month    AS month,
    s.store_id,
    s.product_id,
    SUM(s.total_price)     AS total_sales,
    SUM(s.discount)        AS total_discount,
    SUM(s.quantity)        AS total_quantity,
    SUM(s.dwh_net_price)   AS net_sales,
    SUM(s.dwh_gross_profit) AS gross_profit
FROM silver.csv_sales s
GROUP BY s.dwh_sale_by_year, s.dwh_sale_by_month, s.store_id, s.product_id;
GO

-- ===============================
-- FACT VIEW: Store Revenue
-- ===============================
CREATE OR ALTER VIEW gold.vw_fact_store_revenue AS
SELECT
    s.store_id,
    st.store_name,
    st.dwh_is_franchise,
    st.city,
    st.state,
    st.country,
    s.dwh_sale_by_year AS year,
    s.dwh_sale_by_month AS month,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    SUM(s.total_price) AS total_revenue,
    SUM(s.quantity) AS total_units_sold
FROM silver.csv_sales s
JOIN silver.csv_stores st ON s.store_id = st.store_id
GROUP BY s.store_id, st.store_name, st.dwh_is_franchise, st.city, st.state, st.country, s.dwh_sale_by_year, s.dwh_sale_by_month;
GO
-- ===============================
-- DIM VIEW: Product Performance
-- ===============================
CREATE OR ALTER VIEW gold.vw_dim_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.dwh_price_category,
    s.dwh_sale_by_year AS year,
    s.dwh_sale_by_month AS month,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_price) AS total_revenue,
    SUM(s.dwh_gross_profit) AS gross_profit
FROM silver.csv_sales s
JOIN silver.csv_products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.dwh_price_category, s.dwh_sale_by_year, s.dwh_sale_by_month;
GO
-- ===============================
-- DIM VIEW: Customer Value
-- ===============================
CREATE OR ALTER VIEW gold.vw_dim_customer_value AS
SELECT
    c.customer_id,
    c.dwh_full_name,
    c.dwh_email_doman,
    c.country,
    s.dwh_sale_by_year AS year,
    s.dwh_sale_by_month AS month,
    SUM(s.total_price) AS total_spent,
    COUNT(DISTINCT s.sales_id) AS total_orders
FROM silver.csv_sales s
JOIN silver.csv_customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.dwh_full_name, c.dwh_email_doman, c.country, s.dwh_sale_by_year, s.dwh_sale_by_month;
GO
-- ===============================
-- FACT VIEW: Inventory Snapshot
-- ===============================
CREATE OR ALTER VIEW gold.vw_fact_inventory_snapshot AS
SELECT
    i.product_id,
    i.store_id,
    c.year,
    c.month,
    AVG(i.stock_level) AS avg_stock_level,
    MAX(CAST(i.dwh_is_low_stock AS INT)) AS had_low_stock
FROM silver.csv_inventory i
JOIN silver.csv_calendar c ON i.stock_date = c.date
GROUP BY i.product_id, i.store_id, c.year, c.month;
GO
