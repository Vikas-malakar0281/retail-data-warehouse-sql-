/*
===============================================================================
DDL Script: Silver Tables (Raw Data cleaning and Transformation Layer)
===============================================================================
📌 Script Purpose:
    Define 'int' tables to hold raw data from CSV files (pipe-delimited '|').

⚠️ Warning:
    This script drops existing silver.* tables if they already exist.
    All current data will be lost — use with caution in production environments.
===============================================================================
*/

USE retail_data_warehouse_sql;
GO

-- ===========================
-- Customers
-- ===========================
IF OBJECT_ID('silver.csv_customers', 'U') IS NOT NULL
    DROP TABLE silver.csv_customers;
GO

CREATE TABLE silver.csv_customers (
    customer_id     INT,
    first_name      NVARCHAR(100),
    last_name       NVARCHAR(100),
    email           NVARCHAR(255),
    phone_number    NVARCHAR(50),
    city            NVARCHAR(100),
    state           NVARCHAR(100),
    country         NVARCHAR(150),
    signup_date     DATE,
    meta_colume     DATETIME DEFAULT GETDATE()
);
GO

-- ===========================
-- Calendar
-- ===========================
IF OBJECT_ID('silver.csv_calendar', 'U') IS NOT NULL
    DROP TABLE silver.csv_calendar;
GO

CREATE TABLE silver.csv_calendar (
    date            DATE,
    day             INT,
    month           INT,
    year            INT,
    weekday         NVARCHAR(15),
    is_weekend      NVARCHAR(5) -- could be 'TRUE'/'FALSE'
,   meta_colume     DATETIME DEFAULT GETDATE()
);
GO

-- ===========================
-- Inventory
-- ===========================
IF OBJECT_ID('silver.csv_inventory', 'U') IS NOT NULL
    DROP TABLE silver.csv_inventory;
GO

CREATE TABLE silver.csv_inventory (
    product_id      INT,
    store_id        INT,
    stock_date      DATE,
    stock_level     INT,
    meta_colume     DATETIME DEFAULT GETDATE()
);
GO

-- ===========================
-- Products
-- ===========================
IF OBJECT_ID('silver.csv_products', 'U') IS NOT NULL
    DROP TABLE silver.csv_products;
GO

CREATE TABLE silver.csv_products (
    product_id      INT,
    product_name    NVARCHAR(150),
    category        NVARCHAR(100),
    price           FLOAT,
    cost            FLOAT,
    meta_colume     DATETIME DEFAULT GETDATE()
);
GO

-- ===========================
-- Sales
-- ===========================
IF OBJECT_ID('silver.csv_sales', 'U') IS NOT NULL
    DROP TABLE silver.csv_sales;
GO

CREATE TABLE silver.csv_sales (
    sales_id        INT,
    date            DATE,
    store_id        INT,
    product_id      INT,
    customer_id     INT,
    quantity        INT,
    unit_price      FLOAT,
    discount        FLOAT,
    total_price     FLOAT,
    meta_colume     DATETIME DEFAULT GETDATE()
);
GO

-- ===========================
-- Stores
-- ===========================
IF OBJECT_ID('silver.csv_stores', 'U') IS NOT NULL
    DROP TABLE silver.csv_stores;
GO

CREATE TABLE silver.csv_stores (
    store_id        INT,
    store_name      NVARCHAR(150),
    city            NVARCHAR(100),
    state           NVARCHAR(100),
    country         NVARCHAR(100),
     meta_colume     DATETIME DEFAULT GETDATE()
);
GO





