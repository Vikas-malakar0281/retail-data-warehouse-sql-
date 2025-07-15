USE retail_data_warehouse_sql;
GO

-- ============================================
-- File: gold_views.sql
-- Purpose: Create Gold Layer Views for Analytics
-- ============================================

-- =================================================
-- 1. FACT VIEW: Sales Summary by Store & Product
-- =================================================
CREATE OR ALTER VIEW gold.vw_fact_sales_summary AS
SELECT
    cs.dwh_sale_by_year   AS year,
    cs.dwh_sale_by_month  AS month,
    cs.store_id,
    cs.product_id,
    SUM(cs.total_price)   AS total_sales,
    SUM(cs.discount)      AS total_discount,
    SUM(cs.quantity)      AS total_quantity
FROM silver.csv_sales cs
GROUP BY 
    cs.dwh_sale_by_year, 
    cs.dwh_sale_by_month, 
    cs.store_id, 
    cs.product_id;
GO
-- Purpose: Track monthly sales performance per store and product.

-- ======================================================
-- 2. DIMENSION VIEW: Customer Lifetime Value
-- ======================================================
CREATE OR ALTER VIEW gold.vw_dim_customer_value AS
SELECT
    cs.customer_id,
    c.dwh_full_name        AS customer_name,
    c.country              AS customer_country,
    MIN(cs.dwh_sale_by_year) AS first_purchase_year,
    MAX(cs.dwh_sale_by_year) AS last_purchase_year,
    COUNT(DISTINCT cs.sales_id) AS total_orders,
    SUM(cs.total_price)        AS total_spent,
    MIN(cs.date)               AS first_order_date,
    MAX(cs.date)               AS last_order_date
FROM silver.csv_sales cs
LEFT JOIN silver.csv_customers c 
    ON cs.customer_id = c.customer_id
GROUP BY 
    cs.customer_id, 
    c.dwh_full_name, 
    c.country;
GO
-- Purpose: Provide a complete view of each customer's lifetime value and activity.

-- ===========================================
-- 3. FACT VIEW: Product Performance by Month
-- ===========================================
CREATE OR ALTER VIEW gold.vw_fact_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    cs.dwh_sale_by_year   AS year,
    cs.dwh_sale_by_month  AS month,
    SUM(cs.quantity)      AS total_units_sold,
    SUM(cs.total_price)   AS total_revenue
FROM silver.csv_sales cs
LEFT JOIN silver.csv_products p 
    ON cs.product_id = p.product_id
GROUP BY 
    p.product_id, 
    p.product_name, 
    p.category, 
    cs.dwh_sale_by_year, 
    cs.dwh_sale_by_month;
GO
-- Purpose: Analyze product sales and revenue trends over time.

-- ==================================
-- 4. DIMENSION VIEW: Product Master
-- ==================================
CREATE OR ALTER VIEW gold.vw_dim_product AS
SELECT
    product_id,
    product_name,
    category,
    price,
    cost,
    dwh_profit_margin,
    dwh_price_category,

    -- Derived column: % markup
    CAST((price - cost) * 100.0 / NULLIF(cost, 0) AS DECIMAL(10,2)) AS markup_percent,

    -- Derived column: Profit category
    CASE 
        WHEN dwh_profit_margin >= 100 THEN 'High Margin'
        WHEN dwh_profit_margin >= 50 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS margin_category,

    creationdate AS product_created_date
FROM silver.csv_products;
GO
-- Purpose: Enriched product dimension with pricing and profitability insights.

-- ====================================
-- 5. FACT VIEW: Inventory Snapshot
-- ====================================
CREATE OR ALTER VIEW gold.vw_fact_inventory_snapshot AS
SELECT
    s.dwh_sale_by_year AS year,
    s.dwh_sale_by_month AS month,
    s.store_id,
    i.product_id,
    i.stock_date,
    i.stock_level
FROM silver.csv_inventory i
LEFT JOIN silver.csv_sales s 
    ON i.product_id = s.product_id
GROUP BY 
    s.dwh_sale_by_year,
    s.dwh_sale_by_month,
    s.store_id,
    i.product_id,
    i.stock_date,
    i.stock_level;
GO
-- Purpose: Monitor monthly stock levels by product and store.

-- =====================================
-- 6. FACT VIEW: Store Revenue Summary
-- =====================================
CREATE OR ALTER VIEW gold.vw_fact_store_revenue AS
SELECT
    s.store_id,
    s.store_name,
    s.dwh_2ndstore_name AS store_type,
    s.country           AS store_country,
    cs.dwh_sale_by_year AS year,
    cs.dwh_sale_by_month AS month,
    COUNT(DISTINCT cs.customer_id) AS unique_customers_id,
    SUM(cs.total_price)            AS revenue,
    SUM(cs.quantity)               AS total_units
FROM silver.csv_sales cs
LEFT JOIN silver.csv_stores s 
    ON cs.store_id = s.store_id
GROUP BY 
    s.store_id, 
    s.store_name, 
    s.dwh_2ndstore_name, 
    s.country, 
    cs.dwh_sale_by_year, 
    cs.dwh_sale_by_month;
GO
-- Purpose: Evaluate revenue and customer activity across stores monthly.

-- ===============================================
-- 7. FACT VIEW: Customer Monthly Purchase Summary
-- ===============================================
CREATE OR ALTER VIEW gold.vw_fact_customer_monthly_summary AS
SELECT
    cs.customer_id,
    c.dwh_full_name AS customer_name,
    cs.dwh_sale_by_year AS year,
    cs.dwh_sale_by_month AS month,
    COUNT(DISTINCT cs.sales_id) AS orders_count,
    SUM(cs.total_price)         AS total_spent,
    SUM(cs.quantity)            AS total_units
FROM silver.csv_sales cs
LEFT JOIN silver.csv_customers c 
    ON cs.customer_id = c.customer_id
GROUP BY 
    cs.customer_id, 
    c.dwh_full_name, 
    cs.dwh_sale_by_year, 
    cs.dwh_sale_by_month;
GO
-- Purpose: Track customer purchase behavior over time by month.

-- ======================================
-- 8. FACT VIEW: Category Performance
-- ======================================
CREATE OR ALTER VIEW gold.vw_fact_category_performance AS
SELECT
    p.category,
    cs.dwh_sale_by_year AS year,
    cs.dwh_sale_by_month AS month,
    SUM(cs.quantity)    AS total_units_sold,
    SUM(cs.total_price) AS total_revenue
FROM silver.csv_sales cs
LEFT JOIN silver.csv_products p 
    ON cs.product_id = p.product_id
GROUP BY 
    p.category, 
    cs.dwh_sale_by_year, 
    cs.dwh_sale_by_month;
GO
-- Purpose: Monitor overall performance of each product category monthly.

-- =======================================================
-- 9. FACT VIEW: Store-Category Combined Performance
-- =======================================================
CREATE OR ALTER VIEW gold.vw_fact_store_category_performance AS
SELECT
    s.store_id,
    s.store_name,
    p.category,
    cs.dwh_sale_by_year AS year,
    cs.dwh_sale_by_month AS month,
    SUM(cs.total_price) AS total_revenue,
    SUM(cs.quantity)    AS total_units_sold
FROM silver.csv_sales cs
LEFT JOIN silver.csv_stores s 
    ON cs.store_id = s.store_id
LEFT JOIN silver.csv_products p 
    ON cs.product_id = p.product_id
GROUP BY 
    s.store_id,
    s.store_name,
    p.category,
    cs.dwh_sale_by_year,
    cs.dwh_sale_by_month;
GO
-- Purpose: Compare category sales across stores and time for cross-segment insights.
