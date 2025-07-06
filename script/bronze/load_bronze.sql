USE [retail_data_warehouse_sql]
GO
/****** Object:  StoredProcedure [bronze].[load_bronze]    Script Date: 6/30/2025 4:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
    - Logs the start and end time of each load operation.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
ALTER   PROCEDURE [bronze].[load_bronze] AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_calendar';
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.csv_calendar;
        BULK INSERT bronze.csv_calendar
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\calendar.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_customers';
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.csv_customers;
        BULK INSERT bronze.csv_customers
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_inventory';
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.csv_inventory;
        BULK INSERT bronze.csv_inventory
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\inventory.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_products';
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.csv_products;
        BULK INSERT bronze.csv_products
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_sales';
        ------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.csv_sales;
        BULK INSERT bronze.csv_sales
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\sales.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ------------------------------------------------
        PRINT '>> Truncating and Loading: bronze.csv_stores';
        ------------------------------------------------
        SET @start_time = GETDATE()
       TRUNCATE TABLE bronze.csv_stores;

        BULK INSERT bronze.csv_stores
        FROM 'C:\SQL2022\retail-data-warehouse-sql-\datasets\stores.csv'
        WITH (
            FORMAT = 'CSV',            -- enables proper parsing of quoted fields
            FIRSTROW = 2,
            FIELDQUOTE = '"',          -- required since store_name and country are contain commas
            ROWTERMINATOR = '0x0a',    -- explicitly handle Unix-style newlines
            TABLOCK                     -- improve bulk load performance
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();
        PRINT '=========================================='
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=========================================='
    END TRY
    BEGIN CATCH
        PRINT '=========================================='
        PRINT '❌ ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
END

