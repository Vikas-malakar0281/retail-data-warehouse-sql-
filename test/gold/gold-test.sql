-- ==========================================
-- ✅ Index Usage Test Queries for Gold Layer
-- ==========================================

-- ------------------------------------------
-- Test for IX_sales_year_month_store_product
-- Should filter using year and store_id
-- Used in: vw_fact_sales_summary
-- ------------------------------------------
SELECT *
FROM gold.vw_fact_sales_summary
WHERE year = 2023 AND store_id = 101;


-- ------------------------------------------
-- Test for IX_sales_customer_year_month
-- Filters customer across time
-- Used in: vw_fact_customer_monthly_summary
-- ------------------------------------------
SELECT *
FROM gold.vw_fact_customer_monthly_summary
WHERE customer_id = 500;


-- ------------------------------------------
-- Test for IX_sales_product_year_month
-- Checks product performance
-- Used in: vw_fact_product_performance
-- ------------------------------------------
SELECT *
FROM gold.vw_fact_product_performance
WHERE product_id = 201;


-- ------------------------------------------
-- Test for IX_inventory_product_stock_date
-- Used in: vw_fact_inventory_snapshot
-- ------------------------------------------
SELECT *
FROM gold.vw_fact_inventory_snapshot
WHERE product_id = 305 AND stock_date = '2023-12-01';


-- =============================
-- ✅ Direct Silver Layer Checks
-- =============================

-- Test for IX_calendar_date
SELECT *
FROM silver.csv_calendar
WHERE date = '2023-06-15';

-- Test for IX_customers_id
SELECT *
FROM silver.csv_customers
WHERE customer_id = 1050;

-- Test for IX_stores_franchise
SELECT *
FROM silver.csv_stores
WHERE dwh_is_franchise = 'YES';

-- Test for IX_products_price_category
SELECT *
FROM silver.csv_products
WHERE dwh_price_category = 'High';
