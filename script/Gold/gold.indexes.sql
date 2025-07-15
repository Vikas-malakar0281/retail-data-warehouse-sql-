-- File: gold_refresh_proc_and_indexes.sql
-- Purpose: Create procedure to refresh Gold views (metadata-driven) and apply indexes where needed

-- =====================================
-- STORED PROCEDURE: Refresh Gold Layer
-- =====================================
CREATE OR ALTER PROCEDURE gold.refresh_gold_views
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME = GETDATE();

    PRINT 'Refreshing Gold Layer Views...';
    -- These views are metadata-only (no data persisted), so no actual refresh needed
    -- But this can be used for logging/reporting or used by downstream tools

    PRINT 'Gold Views ready for BI consumption.';
    PRINT 'Completed at: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS NVARCHAR) + ' seconds';
END;
GO

-- =====================================
-- SUGGESTED NONCLUSTERED INDEXES (on Silver Layer Tables for faster Gold Views)
-- =====================================
-- Indexes improve JOIN and GROUP BY performance

-- =====================================
-- Optimized Index Creation for Gold Layer Queries
-- =====================================

-- ==================================================
-- 1. Indexes on silver.csv_sales
-- Used heavily across most fact views
-- ==================================================

CREATE NONCLUSTERED INDEX IX_sales_year_month_store_product
ON silver.csv_sales (dwh_sale_by_year, dwh_sale_by_month, store_id, product_id)
INCLUDE (total_price, discount, quantity);

CREATE NONCLUSTERED INDEX IX_sales_customer_year_month
ON silver.csv_sales (customer_id, dwh_sale_by_year, dwh_sale_by_month)
INCLUDE (sales_id, total_price, quantity);

CREATE NONCLUSTERED INDEX IX_sales_product_year_month
ON silver.csv_sales (product_id, dwh_sale_by_year, dwh_sale_by_month)
INCLUDE (quantity, total_price);


-- ==================================================
-- 2. Index on silver.csv_inventory
-- Used in vw_fact_inventory_snapshot
-- ==================================================

CREATE NONCLUSTERED INDEX IX_inventory_product_stock_date
ON silver.csv_inventory (product_id, stock_date)
INCLUDE (store_id, stock_level);


-- ==================================================
-- 3. Index on silver.csv_calendar
-- For any date-based joins
-- ==================================================

CREATE NONCLUSTERED INDEX IX_calendar_date
ON silver.csv_calendar (date);


-- ==================================================
-- 4. Index on silver.csv_customers
-- Used in customer value, monthly summary
-- ==================================================

CREATE NONCLUSTERED INDEX IX_customers_id
ON silver.csv_customers (customer_id)
INCLUDE (dwh_full_name, country);

-- ==================================================
-- Additional Indexes : You can ignore this indexes if 
-- you want because our store table has only 200 rows
-- inside it. Its so small that sql will ignore the index 
-- and scann the whole table because it is eficient
-- Its a different story if we have bigger datas.
-- This indexes can be help full at that time.
-- ==================================================

/*

-- ==================================================
-- 5. Index on silver.csv_stores
-- Used in store revenue, store-category performance
-- ==================================================

===================================================
CREATE NONCLUSTERED INDEX IX_stores_franchise
ON silver.csv_stores (dwh_is_franchise)
INCLUDE (store_id, store_name, country);

====================================================


-- ==================================================
-- 6. Index on silver.csv_products
-- Used in product/category performance views
-- ==================================================

CREATE NONCLUSTERED INDEX IX_products_price_category
ON silver.csv_products (dwh_price_category)
INCLUDE (product_id, product_name, category, price, cost);

=====================================================

*/
