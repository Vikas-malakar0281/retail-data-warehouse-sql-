# 🧾 Naming Conventions

This document outlines the naming conventions used in the **Retail Data Warehouse Project**, specifically designed around the provided dataset. It ensures clarity, consistency, and professional structure across staging, intermediate, and business layers.

---

## 📚 Table of Contents
- [General Principles](#general-principles)
- [Table Naming Conventions](#table-naming-conventions)
  - [Bronze Layer](#bronze-layer)
  - [Silver Layer](#silver-layer)
  - [Gold Layer](#gold-layer)
- [Column Naming Conventions](#column-naming-conventions)
  - [Surrogate Keys](#surrogate-keys)
  - [Technical Columns](#technical-columns)
- [Stored Procedures](#stored-procedures)

---

## 🔧 General Principles

- **Style:** Use `snake_case` (lowercase, words separated by underscores)
- **Language:** Use **English** for all naming
- **Reserved Words:** Avoid SQL reserved keywords
- **Consistency:** Reflect data origin and layer clearly

---

## 🗂 Table Naming Conventions

### 🥉 Bronze Layer (Staging)

- **Pattern:** `csv_<entity>`
- **Purpose:** Raw data loaded directly from CSVs with no transformation.
- **Examples:**
  - `bronze.csv_customers`
  - `bronze.csv_products`
  - `bronze.csv_sales`
  - `bronze.csv_inventory`
  - `bronze.csv_stores`
  - `bronze.csv_calendar`

### 🥈 Silver Layer (Cleaned & Transformed)

- **Pattern:** `int_<entity>`
- **Purpose:** Cleaned, deduplicated, and standardized tables.
- **Examples:**
  - `silver.int_customers`
  - `silver.int_products`
  - `silver.int_sales`
  - `silver.int_inventory`
  - `silver.int_stores`
  - `silver.int_calendar`

### 🥇 Gold Layer (Business/Reporting Layer)

- **Pattern:** `dim_<entity>` for dimension tables  
                 `fact_<entity>` for fact tables
- **Purpose:** Business-aligned model for reporting and analysis.
- **Examples:**
  - `dim_customer`
  - `dim_product`
  - `dim_store`
  - `dim_date`
  - `fact_sales`
  - `fact_inventory_snapshot`

---

## 🔑 Column Naming Conventions

### Surrogate Keys

- **Pattern:** `<table>_key`
- **Usage:** Primary keys for dimension tables
- **Examples:**
  - `customer_key` in `dim_customer`
  - `product_key` in `dim_product`

### Technical Columns

- **Pattern:** `dwh_<column_name>`
- **Usage:** System-generated or metadata tracking
- **Examples:**
  - `dwh_load_date` → Date record was loaded
  - `dwh_insert_job` → ETL job or process

---

## 🛠 Stored Procedures

- **Pattern:** `load_<layer>`
- **Examples:**
  - `load_bronze` → Load CSVs to staging
  - `load_silver` → Transform staging to clean layer
  - `load_gold` → Build fact and dimension tables

---

## ✅ Summary

By following this naming convention:

- ✅ Your SQL code will be more readable  
- 🧰 ETL pipelines are easier to maintain  
- 🧱 Your project structure aligns with professional data engineering standards  

| 📁 CSV File       | 🥉 Bronze Table     | 🥈 Silver Table     | 🥇 Gold Object             |
|------------------|---------------------|---------------------|-----------------------------|
| `customers.csv`   | `stg_customers`     | `int_customers`     | `dim_customer`              |
| `products.csv`    | `stg_products`      | `int_products`      | `dim_product`               |
| `sales.csv`       | `stg_sales`         | `int_sales`         | `fact_sales`                |
| `inventory.csv`   | `stg_inventory`     | `int_inventory`     | `fact_inventory_snapshot`   |
| `calendar.csv`    | `stg_calendar`      | `int_calendar`      | `dim_date`                  |
| `stores.csv`      | `stg_stores`        | `int_stores`        | `dim_store`                 |

