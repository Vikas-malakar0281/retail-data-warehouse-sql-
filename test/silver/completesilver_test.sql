USE retail_data_warehouse_sql;
GO

-- ======================================
--  1. Preview Sample Records from Each Table
-- ======================================
SELECT TOP 5 * FROM silver.csv_calendar;
SELECT TOP 5 * FROM silver.csv_customers;
SELECT TOP 5 * FROM silver.csv_inventory;
SELECT TOP 5 * FROM silver.csv_products;
SELECT TOP 5 * FROM silver.csv_sales;
SELECT TOP 5 * FROM silver.csv_stores;

-- ======================================
--  2. Calendar Table Validations
-- ======================================
-- Ensure no NULL dates
SELECT COUNT(*) AS null_dates FROM silver.csv_calendar WHERE [date] IS NULL;

-- Check number of weekend days
SELECT is_weekend, COUNT(*) AS count FROM silver.csv_calendar GROUP BY is_weekend;

-- Validate weekday distribution
SELECT weekday, COUNT(*) AS count FROM silver.csv_calendar GROUP BY weekday ORDER BY count DESC;

-- ======================================
--  3. Customers Table Validations
-- ======================================
-- NULL checks
SELECT COUNT(*) AS null_emails FROM silver.csv_customers WHERE email IS NULL;
SELECT COUNT(*) AS null_signup_dates FROM silver.csv_customers WHERE signup_date IS NULL;

-- Duplicate customer IDs
SELECT customer_id, COUNT(*) AS dup_count
FROM silver.csv_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Most common email domains
SELECT dwh_email_doman, COUNT(*) AS count
FROM silver.csv_customers
GROUP BY dwh_email_doman
ORDER BY count DESC;

-- ======================================
--  4. Products Table Validations
-- ======================================
-- Products with negative profit margin
SELECT * FROM silver.csv_products
WHERE dwh_profit_margin < 0;

-- Count by price category
SELECT dwh_price_category, COUNT(*) AS count
FROM silver.csv_products
GROUP BY dwh_price_category;

-- ======================================
--  5. Stores Table Validations
-- ======================================
-- Store types count
SELECT dwh_is_franchise, COUNT(*) AS count
FROM silver.csv_stores
GROUP BY dwh_is_franchise;

-- Unique store ID count
SELECT COUNT(DISTINCT store_id) AS unique_stores FROM silver.csv_stores;

-- ======================================
--  6. Sales Table Validations
-- ======================================
-- Sales with missing keys
SELECT * FROM silver.csv_sales
WHERE store_id IS NULL OR product_id IS NULL OR customer_id IS NULL;

-- Check if any negative values exist in sales numbers
SELECT * FROM silver.csv_sales
WHERE quantity < 0 OR unit_price < 0 OR discount < 0;

-- Validate derived columns: net price vs calculation
SELECT TOP 10 sales_id, 
    dwh_net_price, 
    (unit_price * quantity) - discount AS expected_net_price
FROM silver.csv_sales
WHERE ABS(dwh_net_price - ((unit_price * quantity) - discount)) > 0.01;

-- ======================================
--  7. Inventory Table Validations
-- ======================================
-- Missing inventory levels
SELECT COUNT(*) AS null_inventory
FROM silver.csv_inventory
WHERE stock_level IS NULL;

-- Distribution of stock level category
SELECT dwh_is_low_stock, COUNT(*) AS count
FROM silver.csv_inventory
GROUP BY dwh_is_low_stock;

-- ======================================
-- 8. Key Relationship Checks
-- ======================================
-- Orphan sales: no matching customer
SELECT COUNT(*) AS orphan_customers
FROM silver.csv_sales s
LEFT JOIN silver.csv_customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orphan sales: no matching store
SELECT COUNT(*) AS orphan_stores
FROM silver.csv_sales s
LEFT JOIN silver.csv_stores st ON s.store_id = st.store_id
WHERE st.store_id IS NULL;

-- Orphan sales: no matching product
SELECT COUNT(*) AS orphan_products
FROM silver.csv_sales s
LEFT JOIN silver.csv_products p ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ======================================
--  9. Sample Join to Validate Relationships
-- ======================================
SELECT TOP 10
    s.sales_id,
    c.dwh_full_name,
    p.product_name,
    st.store_name,
    s.total_price
FROM silver.csv_sales s
JOIN silver.csv_customers c ON s.customer_id = c.customer_id
JOIN silver.csv_products p ON s.product_id = p.product_id
JOIN silver.csv_stores st ON s.store_id = st.store_id;
