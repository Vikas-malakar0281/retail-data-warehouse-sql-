SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [silver].[vw_clean_phone] AS 
    -- This view cleans and formats phone numbers from the bronze layer
    -- It removes formatting characters, extracts extensions, and handles country codes

WITH cleaned_input AS (
    SELECT
        customer_id,
        phone_number AS raw_phone_number,
        
        -- Remove common formatting characters from phone number
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, ' ', ''), '(', ''), ')', ''), '-', ''), '.', '') AS cleaned_phone_number
    FROM bronze.csv_customers
),

extension_split AS (
    SELECT
        customer_id,
        raw_phone_number,

        -- Remove everything after 'x' or 'X' if present (keep base number)
        CASE 
            WHEN CHARINDEX('x', LOWER(cleaned_phone_number)) > 0 THEN 
                LEFT(cleaned_phone_number, CHARINDEX('x', LOWER(cleaned_phone_number)) - 1)
            ELSE cleaned_phone_number
        END AS base_phone_number,

        -- Extract digits after 'x' or 'X' as extension, if present
        CASE 
            WHEN CHARINDEX('x', LOWER(cleaned_phone_number)) > 0 THEN 
                SUBSTRING(cleaned_phone_number, CHARINDEX('x', LOWER(cleaned_phone_number)) + 1, LEN(cleaned_phone_number))
            ELSE NULL
        END AS extension
    FROM cleaned_input
),

country_code_removed AS (
    SELECT
        customer_id,
        raw_phone_number,
        extension,

        -- Strip country code if present (+1 or 001)
        CASE 
            WHEN base_phone_number LIKE '+1%' THEN RIGHT(base_phone_number, LEN(base_phone_number) - 2)
            WHEN base_phone_number LIKE '001%' THEN RIGHT(base_phone_number, LEN(base_phone_number) - 3)
            ELSE base_phone_number
        END AS phone_number
    FROM extension_split
)

SELECT 
    customer_id,
    raw_phone_number,
    phone_number,
    extension
FROM country_code_removed;
GO
