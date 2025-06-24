-- ============================================================================
-- Validation Script: Bronze Layer Data Verification
-- ============================================================================
-- Purpose:
--    This script checks row counts and samples of data from all bronze tables 
--    to verify successful BULK INSERT operations.
-- Usage:
--    Run after executing: EXEC bronze.load_bronze;
-- ============================================================================

PRINT '====================== ROW COUNTS ======================';

-- Row count checks
SELECT 'csv_calendar' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_calendar;
SELECT 'csv_customers' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_customers;
SELECT 'csv_inventory' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_inventory;
SELECT 'csv_products' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_products;
SELECT 'csv_sales' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_sales;
SELECT 'csv_stores' AS TableName, COUNT(*) AS RowCount FROM bronze.csv_stores;

PRINT '====================== TOP 5 RECORDS ======================';

-- Sample top 5 records from each table
PRINT '--- bronze.csv_calendar ---';
SELECT TOP 5 * FROM bronze.csv_calendar;

PRINT '--- bronze.csv_customers ---';
SELECT TOP 5 * FROM bronze.csv_customers;

PRINT '--- bronze.csv_inventory ---';
SELECT TOP 5 * FROM bronze.csv_inventory;

PRINT '--- bronze.csv_products ---';
SELECT TOP 5 * FROM bronze.csv_products;

PRINT '--- bronze.csv_sales ---';
SELECT TOP 5 * FROM bronze.csv_sales;

PRINT '--- bronze.csv_stores ---';
SELECT TOP 5 * FROM bronze.csv_stores;
