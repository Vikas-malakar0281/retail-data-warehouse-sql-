USE [retail_data_warehouse_sql];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER VIEW [silver].[vw_store_country] AS
SELECT 
    store_id,
    country,

    -- Extract the main country before the first comma or ' and '
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
    -- If both comma and ' and ' are present, take the middle portion (between comma and 'and')
    -- If only comma is present, take everything after the comma
    -- Otherwise, return 'n/a'
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
    -- Only if 'and' exists after a comma
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX(',', country) > 0 AND CHARINDEX(' and ', country) > CHARINDEX(',', country) THEN
                SUBSTRING(country, CHARINDEX(' and ', country) + 5, LEN(country))
            ELSE 'n/a'
        END
    )) AS branch2

FROM bronze.csv_stores;
GO


