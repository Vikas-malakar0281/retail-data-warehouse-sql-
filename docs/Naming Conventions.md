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
  - `csv_customers`
  - `csv_products`
  - `csv_sales`
  - `csv_inventory`
  - `csv_stores`
  - `csv_calendar`

### 🥈 Silver Layer (Cleaned & Transformed)

- **Pattern:** `int_<entity>`
- **Purpose:** Cleaned, deduplicated, and standardized tables.
- **Examples:**
  - `int_customers`
  - `int_products`
  - `int_sales`
  - `int_inventory`
  - `int_stores`
  - `int_calendar`

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
- Your SQL code will be more readable
- ETL pipelines are easier to maintain
- Your project structure aligns with professional data engineering standards
