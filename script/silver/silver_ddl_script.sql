/*==================================================================
    Purpose : 
        This script creates and transforms the silver layer tables 
        in the `retail_data_warehouse_sql` database. It is part of 
        the data warehouse ETL pipeline and prepares cleaned, 
        structured data from the bronze layer for analytical use.

-------------------------------------------------------------------
    ⚠️ Warning :
        This script will DROP existing silver layer tables if they 
        exist and CREATE them from scratch. Any existing data in 
        these tables will be permanently deleted.

-------------------------------------------------------------------
    ✅ Advice :
        Take a full backup of the silver layer tables if they 
        contain important data before executing this script.
==================================================================*/

USE retail_data_warehouse_sql;
GO

-- ================================
-- 1. Silver: CSV_Calendar
-- ================================
IF OBJECT_ID('silver.csv_calendar', 'U') IS NOT NULL DROP TABLE silver.csv_calendar;
GO
CREATE TABLE silver.csv_calendar (
    date DATE,
    day INT,
    month NVARCHAR(20),
    year INT,
    weekday VARCHAR(20),
    is_weekend BIT, -- 1 = weekend, 0 = weekday
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 2. Silver: CSV_Customers
-- ================================
IF OBJECT_ID('silver.csv_customers', 'U') IS NOT NULL DROP TABLE silver.csv_customers;
GO
CREATE TABLE silver.csv_customers (
    customer_id INT,
    full_name VARCHAR(50),  -- Derived from first and last name
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    email_doman VARCHAR(50), -- Extracted domain from email
    phone_number VARCHAR(18),
    phone_exten VARCHAR(10),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE,
    signup_year DATE, -- Redundant, but stored for year-based analysis
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 3. Silver: CSV_Products
-- ================================
IF OBJECT_ID('silver.csv_products', 'U') IS NOT NULL DROP TABLE silver.csv_products;
GO
CREATE TABLE silver.csv_products (
    product_id INT,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2),
    cost DECIMAL(10, 2),
    profit_margin DECIMAL(10, 2), -- price - cost
    price_category VARCHAR(20),   -- e.g., Low, Medium, High
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 4. Silver: CSV_Stores
-- ================================
IF OBJECT_ID('silver.csv_stores', 'U') IS NOT NULL DROP TABLE silver.csv_stores;
GO
CREATE TABLE silver.csv_stores (
    store_id INT,
    store_name VARCHAR(255),
    dwh_category VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 5. Silver: CSV_Sales
-- ================================
IF OBJECT_ID('silver.csv_sales', 'U') IS NOT NULL DROP TABLE silver.csv_sales;
GO
CREATE TABLE silver.csv_sales (
    sales_id INT,
    date DATE,
    sale_by_month NVARCHAR(20), -- Full month name from date (e.g., 'July')
    sale_by_year INT,           -- Extracted year from date
    store_id INT,
    product_id INT,
    product_name NVARCHAR(50),  -- Joined from products table
    customer_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    net_price DECIMAL(10, 2),   -- unit_price * quantity - discount
    gross_profit DECIMAL(10, 2),-- (unit_price - cost) * quantity
    discount DECIMAL(5, 2),
    total_price DECIMAL(10, 2),
    creationdate DATETIME DEFAULT GETDATE()
);

-- ================================
-- 6. Silver: CSV_Inventory
-- ================================
IF OBJECT_ID('silver.csv_inventory', 'U') IS NOT NULL DROP TABLE silver.csv_inventory;
GO
CREATE TABLE silver.csv_inventory (
    product_id INT,
    store_id INT,
    stock_date DATE,
    stock_level INT,
    is_low_stock NVARCHAR(20), -- 'Yes' or 'No' based on stock threshold
    creation_date DATETIME DEFAULT GETDATE()
);
