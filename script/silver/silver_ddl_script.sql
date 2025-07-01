
/*
===============================================================================
Script Name: Silver Layer - Table Creation Script
Purpose:
    This script creates cleaned, transformed Silver Layer tables from the
    raw Bronze Layer in the [retail_data_warehouse_sql] database.
    These tables serve as standardized and enriched data for reporting,
    analytics, or loading into Gold Layer marts.
===============================================================================
*/

USE retail_data_warehouse_sql;
GO

-- ================================
-- 1. Silver: CSV_Calendar
-- ================================
IF OBJECT_ID('silver.csv_calendar', 'U') IS NOT NULL 
    DROP TABLE silver.csv_calendar;
GO
CREATE TABLE silver.csv_calendar (
    date DATE,
    day INT,
    month NVARCHAR(20),        -- Month name (e.g., 'January')
    year INT,
    weekday VARCHAR(20),
    is_weekend BIT,            -- 1 = weekend, 0 = weekday
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 2. Silver: CSV_Customers
-- ================================
IF OBJECT_ID('silver.csv_customers', 'U') IS NOT NULL 
    DROP TABLE silver.csv_customers;
GO
CREATE TABLE silver.csv_customers (
    customer_id INT,
    full_name VARCHAR(50),             -- Concatenated from first_name + last_name
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    email_doman VARCHAR(50),           -- Extracted from email (e.g., gmail.com)
    phone_number VARCHAR(18),
    phone_exten VARCHAR(10),           -- Extension extracted from phone number, if any
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),              -- Cleaned of region info like "(XYZ)"
    signup_date DATE,
    signup_year DATE,                  -- Derived as DATEFROMPARTS(YEAR(signup_date), 1, 1)
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 3. Silver: CSV_Products
-- ================================
IF OBJECT_ID('silver.csv_products', 'U') IS NOT NULL 
    DROP TABLE silver.csv_products;
GO
CREATE TABLE silver.csv_products (
    product_id INT,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2),
    cost DECIMAL(10, 2),
    profit_margin DECIMAL(10, 2),      -- Calculated as price - cost
    price_category VARCHAR(20),        -- Derived tier: High / Medium / Low
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 4. Silver: CSV_Stores
-- ================================
IF OBJECT_ID('silver.csv_stores', 'U') IS NOT NULL 
    DROP TABLE silver.csv_stores;
GO
CREATE TABLE silver.csv_stores (
    store_id INT,
    store_name VARCHAR(255),           -- Cleaned of surrounding quotes
    city VARCHAR(100),                 -- Cleaned of surrounding quotes
    state VARCHAR(100),
    country VARCHAR(100),
    store_branch1 NVARCHAR(50),        -- Derived from joined view
    store_branch2 NVARCHAR(50),        -- Derived from joined view
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 5. Silver: CSV_Sales
-- ================================
IF OBJECT_ID('silver.csv_sales', 'U') IS NOT NULL 
    DROP TABLE silver.csv_sales;
GO
CREATE TABLE silver.csv_sales (
    sales_id INT,
    date DATE,
    sale_by_month DATE,               -- First day of sale month
    sale_by_year DATE,                -- First day of sale year
    store_id INT,
    product_id INT,
    product_name NVARCHAR(50),
    customer_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    net_price DECIMAL(10, 2),         -- unit_price * quantity - discount
    profit DECIMAL(10, 2),            -- (unit_price - cost) * quantity
    discount DECIMAL(5, 2),
    total_price DECIMAL(10, 2),
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 6. Silver: CSV_Inventory
-- ================================
IF OBJECT_ID('silver.csv_inventory', 'U') IS NOT NULL 
    DROP TABLE silver.csv_inventory;
GO
CREATE TABLE silver.csv_inventory (
    product_id INT,
    store_id INT,
    stock_date DATE,
    stock_level INT,
    is_low_stock NVARCHAR(20),        -- Derived label: 'empty', 'Low', 'Medium', 'High'
    creation_date DATETIME DEFAULT GETDATE()
);

