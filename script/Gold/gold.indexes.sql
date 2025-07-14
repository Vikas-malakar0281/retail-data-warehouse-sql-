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

-- Index for sales fact filtering
CREATE NONCLUSTERED INDEX IX_sales_year_month_store_product
ON silver.csv_sales (dwh_sale_by_year, dwh_sale_by_month, store_id, product_id);
GO

-- Index for customer-based aggregations
CREATE NONCLUSTERED INDEX IX_sales_customer_time
ON silver.csv_sales (customer_id, dwh_sale_by_year, dwh_sale_by_month);

-- Index for product performance
CREATE NONCLUSTERED INDEX IX_sales_product_time
ON silver.csv_sales (product_id, dwh_sale_by_year, dwh_sale_by_month);

-- Index for inventory snapshot
CREATE NONCLUSTERED INDEX IX_inventory_product_store_date
ON silver.csv_inventory (product_id, store_id, stock_date);

-- Index for joining calendar
CREATE NONCLUSTERED INDEX IX_calendar_date
ON silver.csv_calendar (date);

-- Index for joining customer full name
CREATE NONCLUSTERED INDEX IX_customers_id_name
ON silver.csv_customers (customer_id, dwh_full_name);

-- Index for joining store data
CREATE NONCLUSTERED INDEX IX_stores_id_franchise
ON silver.csv_stores (store_id, dwh_is_franchise);

-- Index for joining product metadata
CREATE NONCLUSTERED INDEX IX_products_id_category
ON silver.csv_products (product_id, dwh_price_category);
