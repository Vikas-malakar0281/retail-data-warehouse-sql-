USE retail_data_warehouse_sql;
GO

-- ============================================
-- File: gold_views.sql
-- Purpose: Create Gold Layer Views for Analytics
-- Supports: Power BI Dashboards - Sales, Customers, Inventory
-- ============================================

-- ===================================================
-- 1. FACT VIEW: Sales Summary by Store & Product (Aggregated)
-- Used in: Sales Performance Overview dashboard
-- ===================================================
CREATE OR ALTER VIEW gold.vw_fact_sales_summary AS
SELECT
    dwh_sale_by_year   AS year,                -- Extracted year for time-based grouping
    dwh_sale_by_month  AS month,               -- Extracted month for time-based grouping
    store_id,                                   -- Foreign key to store dimension
    product_id,                                 -- Foreign key to product dimension
    SUM(total_price)   AS total_sales,         -- Aggregated total revenue
    SUM(discount)      AS total_discount,      -- Aggregated discount given
    SUM(quantity)      AS total_quantity       -- Aggregated quantity sold
FROM silver.csv_sales
GROUP BY 
    dwh_sale_by_year, 
    dwh_sale_by_month, 
    store_id, 
    product_id;
GO

-- ===================================================
-- 2. FACT VIEW: Sales Transactions (with sales_id)
-- Used in: Drill-through capability in dashboards
-- ===================================================
CREATE OR ALTER VIEW gold.vw_fact_sales_transactions AS
SELECT
    sales_id   AS sales_orders,                 -- Unique identifier for each sale
    date,                                       -- Date of the transaction
    dwh_sale_by_year   AS year,                -- Year for date-based filtering
    dwh_sale_by_month  AS month,               -- Month for date-based filtering
    store_id,                                   -- Store where the sale happened
    product_id,                                 -- Product sold
    customer_id,                                -- Customer involved in the transaction
    quantity,                                   -- Quantity sold
    unit_price,                                 -- Per unit selling price
    discount,                                   -- Discount offered
    total_price                                 -- Final sale amount after discount
FROM silver.csv_sales;
GO

-- ===================================================
-- 3. DIMENSION VIEW: Customer Lifetime Value
-- Used in: Customer Insights dashboard
-- ===================================================
CREATE OR ALTER VIEW gold.vw_dim_customer_value AS
SELECT
    cs.customer_id,                                              -- Unique customer ID
    c.dwh_full_name        AS customer_name,                     -- Full name for identification
    c.country              AS customer_country,                  -- Country of the customer
    MIN(cs.dwh_sale_by_year) AS first_purchase_year,            -- First year customer made a purchase
    MAX(cs.dwh_sale_by_year) AS last_purchase_year,             -- Most recent year of purchase
    COUNT(DISTINCT cs.sales_id) AS total_orders,                -- Total number of orders placed
    SUM(cs.total_price)        AS total_spent,                  -- Total money spent
    MIN(cs.date)               AS first_order_date,             -- Earliest transaction date
    MAX(cs.date)               AS last_order_date,              -- Latest transaction date
    SUM(cs.total_price) / NULLIF(COUNT(DISTINCT cs.sales_id), 0) AS avg_order_value,      -- Average amount spent per order
    SUM(cs.quantity) / NULLIF(COUNT(DISTINCT cs.sales_id), 0)    AS avg_items_per_order    -- Average quantity per order
FROM silver.csv_sales cs
LEFT JOIN silver.csv_customers c 
    ON cs.customer_id = c.customer_id
GROUP BY 
    cs.customer_id, 
    c.dwh_full_name, 
    c.country;
GO

-- ============================================
-- 4. FACT VIEW: Product Performance by Month
-- Used in: Sales Performance Overview dashboard
-- ============================================
CREATE OR ALTER VIEW gold.vw_fact_product_performance AS
SELECT
    p.product_id,                          -- Product identifier
    p.product_name,                        -- Name of the product
    p.category,                            -- Category to which the product belongs
    cs.dwh_sale_by_year   AS year,        -- Year component of sale date
    cs.dwh_sale_by_month  AS month,       -- Month component of sale date
    SUM(cs.quantity)      AS total_units_sold, -- Total units sold per product per month
    SUM(cs.total_price)   AS total_revenue     -- Total revenue generated
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

-- ====================================
-- 5. FACT VIEW: Inventory Snapshot
-- Used in: Inventory & Stock Levels dashboard
-- ====================================
CREATE OR ALTER VIEW gold.vw_fact_inventory_snapshot AS
SELECT
    s.dwh_sale_by_year AS year,                 -- Year from sales to align timeframes
    s.dwh_sale_by_month AS month,              -- Month from sales to align timeframes
    s.store_id,                                 -- Store identifier
    st.store_name,                              -- Store name for readability
    i.product_id,                               -- Product identifier
    p.product_name,                             -- Product name
    p.category,                                 -- Product category
    i.stock_date,                               -- Inventory snapshot date
    i.stock_level,                              -- Quantity available in stock
    CASE                                        -- Categorize stock status
        WHEN i.stock_level = 0 THEN 'Out of Stock'
        WHEN i.stock_level >= 100 THEN 'Overstocked'
        WHEN i.stock_level < 10 THEN 'Low Stock'
        ELSE 'Normal Stock'
    END AS stock_status
FROM silver.csv_inventory i
LEFT JOIN silver.csv_products p ON i.product_id = p.product_id
LEFT JOIN silver.csv_stores st ON i.store_id = st.store_id
LEFT JOIN silver.csv_sales s ON i.product_id = s.product_id
GROUP BY 
    s.dwh_sale_by_year,
    s.dwh_sale_by_month,
    s.store_id,
    st.store_name,
    i.product_id,
    p.product_name,
    p.category,
    i.stock_date,
    i.stock_level;
GO

-- ===============================================
-- 6. FACT VIEW: Customer Monthly Purchase Summary
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
