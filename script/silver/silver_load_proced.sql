/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    Performs ETL to populate 'silver' schema tables from 'bronze'.
    Actions:
        - Truncates Silver tables
        - Inserts cleansed/transformed data from Bronze

Usage:
    EXEC silver.load_script;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_script AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    SET @start_time = GETDATE();

    PRINT '=======================================';
    PRINT 'Loading Silver Layer';
    PRINT '=======================================';
   
   PRINT'--------------------------------------------------'; 
   PRINT '>> 1.Truncating and Loading silver.csv_customers <<';
   PRINT '-------------------------------------------------';
    -- Step 1: Clear target table
    TRUNCATE TABLE silver.csv_customers;

    -- Step 2: Insert cleansed data from bronze
    INSERT INTO silver.csv_customers (
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        city,
        state,
        country,
        signup_date
        -- meta_column omitted to use default GETDATE()
    )
    SELECT
        t.customer_id,
        t.first_name,
        t.last_name,
        t.email,
        phone_parts.formatted_number AS phone_number,
        t.city,
        t.state,
        CASE 
            WHEN country_cleaned = 'Holy See' THEN 'Vatican City'
            WHEN country_cleaned = 'Timor-Leste' THEN 'East Timor'
            ELSE country_cleaned
        END AS country,
        t.signup_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY signup_date DESC) AS flag_last
        FROM bronze.csv_customers
        WHERE customer_id IS NOT NULL
    ) t

    -- Clean and format phone number (extension is removed)
    CROSS APPLY (
        SELECT
            -- Remove everything after 'x' and format the remaining number
            formatted_number = 
                CASE 
                    WHEN LEFT(base_no, 3) = '001' THEN '+1 ' + STUFF(STUFF(RIGHT(base_no, LEN(base_no) - 3), 4, 0, ' '), 8, 0, ' ')
                    WHEN LEFT(base_no, 1) = '1'   THEN '+1 ' + STUFF(STUFF(RIGHT(base_no, LEN(base_no) - 1), 4, 0, ' '), 8, 0, ' ')
                    ELSE '+' + STUFF(STUFF(base_no, 4, 0, ' '), 8, 0, ' ')
                END
        FROM (
            SELECT base_no = 
                LEFT(clean_no, ISNULL(NULLIF(CHARINDEX('x', clean_no), 0) - 1, LEN(clean_no)))
            FROM (
                SELECT clean_no = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    LOWER(t.phone_number), 'x','x'), ' ', ''), '+', ''), '(', ''), ')', ''), '-', ''), '/', ''), '.', '')
            ) raw
        ) cleaned
    ) phone_parts

    -- Clean country name by removing text after '('
    CROSS APPLY (
        SELECT country_cleaned = RTRIM(LTRIM(
            CASE 
                WHEN CHARINDEX('(', t.country) > 0 THEN LEFT(t.country, CHARINDEX('(', t.country) - 1)
                ELSE t.country
            END
        ))
    ) country_parts

    WHERE t.flag_last = 1;

    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
END;
  PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
    SET @start_time = GETDATE();

   PRINT'--------------------------------------------------'; 
   PRINT '>> 2.Truncating and Loading silver.csv_calendar <<' ;
   PRINT '-------------------------------------------------';

    -- Step 1: Clear target table
    TRUNCATE TABLE silver.csv_calendar;

    -- Step 2: Insert cleansed data from bronze.csv_calendar
    INSERT INTO silver.csv_calendar(
      [date]
      ,[day]
      ,[month]
      ,[year]
      ,[weekday]
      ,[is_weekend]
        -- meta_column omitted to use default GETDATE()
    )SELECT
         [date]
        ,[day]
        ,[month]
        ,[year]
        ,[weekday]
        ,[is_weekend]
    FROM bronze.csv_calendar;
   
   SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
       PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  SET @start_time = GETDATE();

  PRINT'--------------------------------------------------'; 
  PRINT '>> 3.Truncating and Loading silver.csv_inventory <<' ;
  PRINT '-------------------------------------------------';

   -- Step 1: Clear target table
    TRUNCATE TABLE silver.csv_inventory;

    -- Step 2: Insert cleansed data from bronze
    INSERT INTO silver.csv_inventory (
        [product_id]
        ,[store_id]
        ,[stock_date]
        ,[stock_level]
       )
        SELECT 
        [product_id]
      ,[store_id]
      ,[stock_date]
      ,[stock_level]
      FROM [bronze].[csv_inventory]
    
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

    
  SET @start_time = GETDATE();

  PRINT'--------------------------------------------------'; 
  PRINT '>> 4. Truncating and Loading silver.csv_products <<' ;
  PRINT '-------------------------------------------------';


  TRUNCATE TABLE silver.csv_products;

-- Inserting clean data from bronze.csv_products

INSERT INTO [silver].[csv_products]
(
[product_id]
,[product_name]
,[category]
,[price]
,[cost]
) SELECT 
[product_id]
,[product_id]
,[category]
,[price]
,[cost]

FROM [bronze].[csv_products]

SET @end_time= GETDATE();
PRINT '>> Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' seconds';
  PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

   SET @start_time = GETDATE();

  PRINT'--------------------------------------------------'; 
  PRINT '>> 5. Truncating and Loading silver.csv_sales <<' ;
  PRINT '-------------------------------------------------';


  INSERT INTO bronze.csv_sales
  (
    [sales_id]
      ,[date]
      ,[store_id]
      ,[product_id]
      ,[customer_id]
      ,[quantity]
      ,[unit_price]
      ,[discount]
      ,[total_price]
  )
  SELECT 
  [sales_id]
      ,[date]
      ,[store_id]
      ,[product_id]
      ,[customer_id]
      ,[quantity]
      ,[unit_price]
      ,[discount]
      ,[total_price]
    FROM silver.csv_sales

SET @end_time = GETDATE(); 
PRINT '>> Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR)+ ' Seconds';
    PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
   
   SET @start_time = GETDATE();

  PRINT'--------------------------------------------------'; 
  PRINT '>> 6. Truncating and Loading silver.csv_stores <<' ;
  PRINT '-------------------------------------------------';


INSERT INTO silver.csv_stores
(
    [store_id]
      ,[store_name]
      ,[city]
      ,[state]
      ,[country]
) SELECT 
  [store_id]
      , REPLACE(REPLACE(store_name, '"',''), '-', ' ')[store_name]
      ,REPLACE(REPLACE(city, '"',''), '-', ' ')[city]
      ,[state]
      ,LEFT(country, CHARINDEX(',', country + ',') - 1) AS [country]
      FROM bronze.csv_stores
      
SET @end_time = GETDATE(); 
PRINT '>> Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR)+ ' Seconds';
    PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
   
 PRINT '=======================================';
    PRINT ' Silver Layer Loading Completed';
    PRINT '=======================================';
    
