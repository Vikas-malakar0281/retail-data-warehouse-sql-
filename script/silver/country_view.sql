/*==================================================================
    Purpose : 
        This script creates or updates the view [silver].[vw_store_country] 
        which extracts and separates country information and branch details 
        from the raw 'country' column in the bronze.csv_stores table.

-------------------------------------------------------------------
    ⚠️ Warning :
        This script replaces the existing view if it exists. Ensure that 
        no downstream processes are dependent on its current structure 
        before running.

-------------------------------------------------------------------
    ✅ Advice :
        Test the transformation logic with sample data from 
        bronze.csv_stores before applying this in production.
==================================================================*/

USE [retail_data_warehouse_sql]; 
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [silver].[vw_store_country] AS
SELECT 
    store_id,
    country,

    -- Extract the main country name (before comma or ' and ')
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX(',', country) > 0 THEN 
                LEFT(country, CHARINDEX(',', country) - 1)
            WHEN CHARINDEX(' and ', country) > 0 THEN 
                LEFT(country, CHARINDEX(' and ', country) - 1)
            ELSE country
        END
    )) AS c_country,

    -- Extract branch1:
    -- If both comma and 'and' exist, get substring between them
    -- If only comma exists, get substring after comma
    -- Else return 'n/a'
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX(',', country) > 0 AND CHARINDEX(' and ', country) > CHARINDEX(',', country) THEN
                SUBSTRING(
                    country,
                    CHARINDEX(',', country) + 1,
                    CHARINDEX(' and ', country) - CHARINDEX(',', country) - 1
                )
            WHEN CHARINDEX(',', country) > 0 THEN
                SUBSTRING(country, CHARINDEX(',', country) + 1, LEN(country))
            ELSE 'n/a'
        END
    )) AS branch1,

    -- Extract branch2:
    -- If 'and' exists after a comma, get substring after 'and'
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX(',', country) > 0 AND CHARINDEX(' and ', country) > CHARINDEX(',', country) THEN
                SUBSTRING(country, CHARINDEX(' and ', country) + 5, LEN(country))
            ELSE 'n/a'
        END
    )) AS branch2

FROM bronze.csv_stores;
GO
