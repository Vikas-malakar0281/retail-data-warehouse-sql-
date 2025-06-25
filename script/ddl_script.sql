/*
=============================================================================
Create Database and Schemas
=============================================================================
Script Purpose:
    This script creates a new database named 'retail_data_warehouse_sql'.
    If the database already exists, it will be dropped and recreated.
    Additionally, it sets up three schemas within the database:
    - bronze (staging layer)
    - silver (cleansing layer)
    - gold (reporting layer: fact, dim)

⚠️ WARNING:
    This script will DROP the existing 'retail_data_warehouse_sql' database.
    All data will be lost. Please proceed with caution.

💡 TIP:
    Always back up your data before running destructive operations.
*/

USE master;
GO

BEGIN TRY
    -- Check if the database exists
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'retail_data_warehouse_sql')
    BEGIN
        PRINT 'Database [retail_data_warehouse_sql] exists. Dropping it now...';

        -- Force disconnect users and rollback active transactions
        ALTER DATABASE retail_data_warehouse_sql
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

        DROP DATABASE retail_data_warehouse_sql;

        PRINT 'Database [retail_data_warehouse_sql] dropped successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Database [retail_data_warehouse_sql] does not exist. Skipping DROP.';
    END

    -- Create the new database
    CREATE DATABASE retail_data_warehouse_sql;
    PRINT '✅ Database [retail_data_warehouse_sql] created successfully.';
END TRY

BEGIN CATCH
    PRINT '❌ Error occurred: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================================
-- Create Schemas: bronze (stg), silver (int), gold (dw)
-- ============================================================================

USE retail_data_warehouse_sql;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

PRINT '✅ Schemas [bronze], [silver], and [gold] created successfully.';
