SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

        INSERT INTO silver.csv_customers (
            customer_id, dwh_full_name, first_name, last_name, email, dwh_email_doman,
            phone_number, dwh_phone_exten, city, state, country, signup_date, signup_year
        )
        SELECT 
            c.customer_id,
            COALESCE(first_name, '') + ' ' + COALESCE(last_name, '') AS full_name,
            first_name,
            last_name,
            email,
            SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) AS email_doman,
            v.phone_number,
            v.extension,
            city,
            state,
            LTRIM(RTRIM(CASE WHEN CHARINDEX('(', country) > 0 THEN LEFT(country, CHARINDEX('(', country) - 1) ELSE country END)),
            signup_date,
            CASE WHEN signup_date IS NOT NULL THEN DATEFROMPARTS(YEAR(signup_date), 1, 1) ELSE NULL END
        FROM bronze.csv_customers c
        LEFT JOIN silver.vw_cleaned_phone v ON c.customer_id = v.customer_id
        WHERE signup_date IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT ' customers loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_products
        -------------------------------
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.csv_products;

        INSERT INTO silver.csv_products (
            product_id, product_name, category, price, cost, dwh_profit_margin, dwh_price_category
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
          [store_id] ,[store_name] ,[dwh_category] ,[city] ,[state] ,[country]
        )
        SELECT 
            store_id,
            ,CASE
            	  WHEN store_name LIKE '% and Sons' THEN store_name
            	  WHEN store_name LIKE '%-%' THEN store_name
            	  WHEN CHARINDEX(',', store_name)>0 THEN  LEFT(store_name, CHARINDEX(',', store_name) - 1)
            	  WHEN CHARINDEX(' ', store_name)>0 THEN  LEFT(store_name, CHARINDEX(' ', store_name) - 1)
	        END AS s_name
        	,CASE
        		WHEN store_name LIKE '% and Sons' THEN 'u/n'
        		WHEN store_name LIKE '% %' THEN SUBSTRING(store_name, CHARINDEX(' ', store_name),LEN(store_name))
        		else 'u/n'
		    END AS category
             city,
            state,
            country
        FROM bronze.csv_stores 
       
        SET @end_time = GETDATE();
        PRINT ' stores loaded in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

        -------------------------------
        -- Load Silver.csv_sales
        -------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.csv_sales;

        INSERT INTO silver.csv_sales (
            sales_id, date, dwh_sale_by_month, dwh_sale_by_year, store_id, product_id, dwh_product_name,
            customer_id,dwh_cus_name, quantity, unit_price, dwh_net_price, dwh_gross_profit, discount, total_price
        )
        SELECT 
            s.sales_id,
            s.date,
            FORMAT(c.date, 'MMMM') AS sale_by_month,  
            YEAR(c.date) AS sale_by_year,
            s.store_id,
            s.product_id,
            p.product_name,
            s.customer_id,
            cus.dwh_full_name,
            s.quantity,
            s.unit_price,
            (s.unit_price * s.quantity) - s.discount,
            (s.unit_price - p.cost) * s.quantity AS gross_profit,
            s.discount,
            s.total_price
        FROM bronze.csv_sales s
        LEFT JOIN silver.csv_calendar c ON s.date = c.date
        LEFT JOIN silver.csv_customers cus ON s.customer_id = cus.customer_id
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
            product_id, store_id, stock_date, stock_level, dwh_is_low_stock
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
        PRINT '❌ ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
GO
