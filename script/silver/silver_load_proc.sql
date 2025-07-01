-- ================================================
-- Stored Procedure: [silver].[load_proc]
-- Purpose: Load cleaned and transformed data from bronze to silver layer.
-- Adds safety checks and error handling to prevent date conversion failures.
-- ================================================

USE [retail_data_warehouse_sql];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [silver].[load_proc] AS
BEGIN
    DECLARE @start_batch_time DATETIME = GETDATE(),
            @start_time       DATETIME,
            @end_time         DATETIME;

    BEGIN TRY
        PRINT '===============================';
        PRINT ' Starting Silver Layer Load';
        PRINT '===============================';

        -----------------------------
        -- Load Silver.csv_calendar
        -----------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_calendar;

        INSERT INTO silver.csv_calendar (date, day, month, year, weekday, is_weekend)
        SELECT 
            date, 
            day, 
            DATENAME(MONTH, date) AS month,
            year, 
            weekday,
            IIF(is_weekend = 'True', 1, 0)
        FROM bronze.csv_calendar
        WHERE date IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT 'calendar loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_customers
        -------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.csv_customers;

        ;WITH cte_clean_phon AS (
            SELECT customer_id, phone_number FROM bronze.csv_customers
        ),
        cte_clean AS (
            SELECT customer_id,
                   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                       LOWER(phone_number), ' ', ''), '+', ''), '(', ''), ')', ''), '-', ''), '/', ''), '.', '') AS cleaned_phone
            FROM cte_clean_phon
        ),
        cte_split AS (
            SELECT customer_id,
                   LEFT(cleaned_phone, ISNULL(NULLIF(CHARINDEX('x', cleaned_phone) - 1, -1), LEN(cleaned_phone))) AS raw_base,
                   CASE WHEN CHARINDEX('x', cleaned_phone) > 0 THEN RIGHT(cleaned_phone, LEN(cleaned_phone) - CHARINDEX('x', cleaned_phone)) ELSE NULL END AS raw_ext
            FROM cte_clean
        ),
        cte_formatted AS (
            SELECT customer_id,
                   CASE WHEN LEN(raw_base) > 10 THEN '+' + LEFT(raw_base, LEN(raw_base) - 10) + ' ' + RIGHT(raw_base, 10)
                        ELSE '+1 ' + raw_base END AS base_no,
                   ISNULL(raw_ext, 'n/a') AS extension
            FROM cte_split
        )
        INSERT INTO silver.csv_customers (
            customer_id, full_name, first_name, last_name, email, email_doman,
            phone_number, phone_exten, city, state, country, signup_date, signup_year
        )
        SELECT 
            c.customer_id,
            COALESCE(first_name, '') + ' ' + COALESCE(last_name, '') AS full_name,
            first_name,
            last_name,
            email,
            SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) AS email_doman,
            f.base_no,
            f.extension,
            city,
            state,
            LTRIM(RTRIM(CASE WHEN CHARINDEX('(', country) > 0 THEN LEFT(country, CHARINDEX('(', country) - 1) ELSE country END)),
            signup_date,
            CASE WHEN signup_date IS NOT NULL THEN DATEFROMPARTS(YEAR(signup_date), 1, 1) ELSE NULL END
        FROM bronze.csv_customers c
        LEFT JOIN cte_formatted f ON c.customer_id = f.customer_id
        WHERE signup_date IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT ' customers loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_products
        -------------------------------
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
            price - cost,
            CASE WHEN price > 250 THEN 'High'
                 WHEN price > 150 THEN 'Medium'
                 ELSE 'Low' END
        FROM bronze.csv_products;

        SET @end_time = GETDATE();
        PRINT ' products loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_stores
        -------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.csv_stores;

        INSERT INTO silver.csv_stores (
            store_id, store_name, city, state, country, store_branch1, store_branch2
        )
        SELECT 
            s.store_id,
            REPLACE(s.store_name, '"', '') AS store_name,
            REPLACE(s.city, '"', '') AS city,
            s.state,
            sc.c_country,
            sc.branch1,
            sc.branch2
        FROM bronze.csv_stores s
        LEFT JOIN silver.vw_store_country sc ON s.store_id = sc.store_id;

        SET @end_time = GETDATE();
        PRINT ' stores loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_sales
        -------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.csv_sales;

        INSERT INTO silver.csv_sales (
            sales_id, date, sale_by_month, sale_by_year, store_id, product_id, product_name,
            customer_id, quantity, unit_price, net_price, profit, discount, total_price
        )
        SELECT 
            s.sales_id,
            s.date,
            CASE WHEN c.date IS NOT NULL THEN DATEFROMPARTS(YEAR(c.date), MONTH(c.date), 1) ELSE NULL END,
            CASE WHEN c.date IS NOT NULL THEN DATEFROMPARTS(YEAR(c.date), 1, 1) ELSE NULL END,
            s.store_id,
            s.product_id,
            p.product_name,
            s.customer_id,
            s.quantity,
            s.unit_price,
            (s.unit_price * s.quantity) - s.discount,
            (s.unit_price - p.cost) * s.quantity,
            s.discount,
            s.total_price
        FROM bronze.csv_sales s
        LEFT JOIN silver.csv_calendar c ON s.date = c.date
        LEFT JOIN silver.csv_products p ON s.product_id = p.product_id
        WHERE s.date IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT ' sales loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_inventory
        -------------------------------
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
            CASE
                WHEN stock_level = 0 THEN 'empty'
                WHEN stock_level < 50 THEN 'Low'
                WHEN stock_level < 200 THEN 'Medium'
                WHEN stock_level >= 200 THEN 'High'
                ELSE 'n/a'
            END
        FROM bronze.csv_inventory
        WHERE stock_level IS NOT NULL AND stock_date IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT ' inventory loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        PRINT '==========================================';
        PRINT ' All Silver Layer Load Completed';
        PRINT '   - Total Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT '❌ ERROR OCCURRED DURING LOADING';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
