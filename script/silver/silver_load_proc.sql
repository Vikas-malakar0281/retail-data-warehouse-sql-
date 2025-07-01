/*
===============================================================================
DDL Script: Silver Tables (Raw Data cleaning and Transformation Layer)
===============================================================================
📌Procedure: [silver].[load_proc] Load Silver Layer (Bronze -> Silver)
-------------------------------------------------------------------------------
  Purpose:   This procedure populates the Silver Layer tables by cleansing,
           transforming, and loading data from the Bronze Layer.
           It handles formatting, enrichment, and basic categorization.
-------------------------------------------------------------------------------
⚠️ Warning:
    This script drops existing silver.* tables if they already exist.
    All current data will be lost — use with caution in production environments.

-------------------------------------------------------------------------------
Usage:
    EXEC silver.load_script;
===============================================================================
*/
USE [retail_data_warehouse_sql];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


ALTER PROCEDURE [silver].[load_proc] AS
BEGIN
	DECLARE 
        @start_bach_time DATETIME, 
        @end_bach_time DATETIME, 
        @start_time DATETIME, 
        @end_time DATETIME;
 
	BEGIN TRY
		SET @start_bach_time = GETDATE();
		PRINT '===============================';
		PRINT 'Loading Silver Layer';
		PRINT '===============================';

        -- =============================
        -- Load: silver.csv_calendar
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_calendar';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_calendar;

        INSERT INTO silver.csv_calendar (
            date, day, month, year, weekday, is_weekend
        )
        SELECT 
            date, 
            day,
            DATENAME(MONTH, date) AS month,
            year, 
            weekday,
            IIF(is_weekend = 'True', 1, 0)  -- Convert string 'True'/'False' to bit 1/0
        FROM bronze.csv_calendar;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- =============================
        -- Load: silver.csv_customers
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_customers';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_customers;

        -- Clean and standardize phone numbers
        WITH cte_clean_phon AS ( 
            SELECT customer_id AS ci, phone_number AS pn 
            FROM bronze.csv_customers
        ),
        cte_clean AS (
            SELECT 
                ci,
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    LOWER(pn), ' ', ''), '+', ''), '(', ''), ')', ''), '-', ''), '/', ''), '.', '') AS stand_ph
            FROM cte_clean_phon
        ),
        cte_base_no_extension AS (
            SELECT 
                ci,
                LEFT(stand_ph, ISNULL(NULLIF(CHARINDEX('x', stand_ph) - 1, -1), LEN(stand_ph))) AS raw_base_no,
                CASE 
                    WHEN CHARINDEX('x', stand_ph) > 0 THEN RIGHT(stand_ph, LEN(stand_ph) - CHARINDEX('x', stand_ph))
                    ELSE NULL 
                END AS raw_extension
            FROM cte_clean
        ),
        cte_formatted AS (
            SELECT ci,
                CASE 
                    WHEN LEN(raw_base_no) > 10 
                        THEN '+' + LEFT(raw_base_no, LEN(raw_base_no) - 10) + ' ' + RIGHT(raw_base_no, 10)
                        ELSE '+1 ' + raw_base_no
                END AS base_no,
                ISNULL(raw_extension, 'n/a') AS extension
            FROM cte_base_no_extension
        )

        INSERT INTO silver.csv_customers (
            customer_id, full_name, first_name, last_name, email, email_doman, 
            phone_number, phone_exten, city, state, country, signup_date, signup_year
        )
        SELECT 
            c.customer_id,
            COALESCE(first_name, '') + ' ' + COALESCE(last_name, '') AS full_name,
            c.first_name,
            c.last_name,
            c.email,
            SUBSTRING(c.email, CHARINDEX('@', email) + 1, LEN(email)) AS email_doman,
            ccp.base_no,
            ccp.extension,
            c.city,
            c.state,
            -- Remove trailing country info like "(Region)" if present
            LTRIM(RTRIM(
                CASE 
                    WHEN CHARINDEX('(', c.country) > 0 THEN LEFT(c.country, CHARINDEX('(', c.country) - 1) 
                    ELSE c.country 
                END
            )),
            c.signup_date,
            DATEFROMPARTS(YEAR(c.signup_date), 1, 1) AS signup_year
        FROM bronze.csv_customers c
        LEFT JOIN cte_formatted ccp ON c.customer_id = ccp.ci;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- =============================
        -- Load: silver.csv_products
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_products';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_products;

        INSERT INTO silver.csv_products (
            product_id, product_name, category, price, cost, profit_margin, price_category
        )
        SELECT 
            product_id,
            product_name,
            category,
            price,
            cost,
            price - cost AS profit_margin,
            -- Categorize based on price ranges
            CASE 
                WHEN price > 250 THEN 'High' 
                WHEN price > 150 THEN 'Medium' 
                ELSE 'Low' 
            END AS price_category
        FROM bronze.csv_products;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- =============================
        -- Load: silver.csv_stores
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_stores';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_stores;

        INSERT INTO silver.csv_stores (
            store_id, store_name, city, state, country, store_branch1, store_branch2
        )
        SELECT 
            s.store_id,
            REPLACE(s.store_name, '"', '') AS store_name,  -- Clean quotes
            REPLACE(s.city, '"', '') AS city,
            s.state,
            ssc.c_country,
            ssc.branch1,
            ssc.branch2
        FROM bronze.csv_stores s
        LEFT JOIN silver.vw_store_country ssc ON s.store_id = ssc.store_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- =============================
        -- Load: silver.csv_sales
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_sales';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_sales;

        INSERT INTO silver.csv_sales (
            sales_id, date, sale_by_month, sale_by_year,
            store_id, product_id, product_name, customer_id,
            quantity, unit_price, net_price, profit, discount, total_price
        )
        SELECT 
            s.sales_id,
            s.date,
            DATEFROMPARTS(YEAR(c.date), MONTH(c.date), 1) AS sale_by_month,
            DATEFROMPARTS(YEAR(c.date), 1, 1) AS sale_by_year,
            s.store_id,
            s.product_id,
            p.product_name,
            s.customer_id,
            s.quantity,
            s.unit_price,
            (s.unit_price * s.quantity) - s.discount AS net_price,
            (s.unit_price - p.cost) * s.quantity AS profit,
            s.discount,
            s.total_price
        FROM bronze.csv_sales s
        LEFT JOIN silver.csv_calendar c ON s.date = c.date
        LEFT JOIN silver.csv_products p ON s.product_id = p.product_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- =============================
        -- Load: silver.csv_inventory
        -- =============================
        PRINT '---------------------------------------------------';
        PRINT '>> Truncating and Loading: silver.csv_inventory';
        PRINT '---------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_inventory;

        INSERT INTO silver.csv_inventory (
            product_id, store_id, stock_date, stock_level, is_low_stock
        )
        SELECT 
            product_id,
            store_id,
            stock_date,
            stock_level,
            -- Categorize inventory status
            CASE
                WHEN stock_level = 0 THEN 'empty'
                WHEN stock_level < 50 THEN 'Low'
                WHEN stock_level < 200 THEN 'Medium'
                WHEN stock_level >= 200 THEN 'High'
                ELSE 'n/a'
            END AS is_low_stock
        FROM bronze.csv_inventory;

        SET @end_bach_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_bach_time, @end_bach_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    
    END TRY

    BEGIN CATCH
        PRINT '==========================================';
        PRINT '❌ ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
