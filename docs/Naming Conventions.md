# 🧾 Naming Conventions

This document outlines the naming conventions used in the **Retail Data Warehouse Project**, designed around the provided dataset. It ensures clarity, consistency, and professional structure across Silver (cleaned) and Gold (analytics) layers.

---

## 📚 Table of Contents
- [General Principles](#general-principles)
- [Table Naming Conventions](#table-naming-conventions)
  - [Silver Layer](#silver-layer)
  - [Gold Layer](#gold-layer)
- [Column Naming Conventions](#column-naming-conventions)
  - [Surrogate Keys](#surrogate-keys)
  - [Technical Columns](#technical-columns)
- [Stored Procedures](#stored-procedures)
- [Summary](#summary)

---

## 🔧 General Principles

- **Style:** Use `snake_case` (lowercase, words separated by underscores)
- **Language:** English only
- **Avoid Reserved Words:** Do not use SQL reserved keywords
- **Consistency:** Naming should reflect data origin and warehouse layer

---

## 🗂 Table Naming Conventions

### 🥈 Silver Layer (Cleaned & Transformed)

- **Pattern:** `csv_<entity>`
- **Purpose:** Cleaned and standardized tables from raw CSVs.
- **Examples:**
  - `silver.csv_customers`
  - `silver.csv_products`
  - `silver.csv_sales`
  - `silver.csv_inventory`
  - `silver.csv_calendar`
  - `silver.csv_stores`

### 🥇 Gold Layer (Business/Analytics)

- **Pattern:** 
  - `vw_fact_<entity>` for fact views  
  - `vw_dim_<entity>` for dimension views
- **Purpose:** Final analytical views for BI and reporting.
- **Examples:**
  - `gold.vw_fact_sales_summary`
  - `gold.vw_fact_product_performance`
  - `gold.vw_fact_inventory_snapshot`
  - `gold.vw_fact_store_revenue`
  - `gold.vw_fact_customer_monthly_summary`
  - `gold.vw_fact_category_performance`
  - `gold.vw_fact_store_category_performance`
  - `gold.vw_dim_product`
  - `gold.vw_dim_customer_value`

---

## 🔑 Column Naming Conventions

### Surrogate Keys

- **Pattern:** `<table>_key`
- **Usage:** Synthetic primary keys for dimension tables
- **Examples:**
  - `customer_key` in customer dimension (if added)
  - `product_key` in product dimension (if added)

### Technical Columns

- **Pattern:** `dwh_<column_name>`
- **Usage:** Metadata and derived fields for tracking or enrichment
- **Examples:**
  - `dwh_sale_by_year`, `dwh_sale_by_month`
  - `dwh_price_category`, `dwh_profit_margin`
  - `dwh_is_low_stock`, `dwh_is_franchise`

---

## 🛠 Stored Procedures

- **Pattern:** `<layer>.<operation>_<object>`
- **Purpose:** Layer-specific data loads and refresh operations.
- **Examples:**
  - `silver.load_proc` – load transformed data into silver layer
  - `gold.indexes` – refresh and creating indexes for metadata-driven gold views

---

## ✅ Summary

Following this naming convention ensures:

- ✅ Clean and consistent SQL across the project  
- 🚀 Efficient debugging and understanding of ETL logic  
- 📊 Seamless consumption by BI tools like Power BI or Tableau  

| 📁 CSV File       | 🥈 Silver Table             | 🥇 Gold View                        |
|------------------|-----------------------------|-------------------------------------|
| `customers.csv`   | `silver.csv_customers`      | `gold.vw_dim_customer_value`        |
| `products.csv`    | `silver.csv_products`       | `gold.vw_dim_product`               |
| `sales.csv`       | `silver.csv_sales`          | `gold.vw_fact_sales_summary`, `vw_fact_customer_monthly_summary`, etc. |
| `inventory.csv`   | `silver.csv_inventory`      | `gold.vw_fact_inventory_snapshot`   |
| `calendar.csv`    | `silver.csv_calendar`       | *Used in joins only*                |
| `stores.csv`      | `silver.csv_stores`         | `gold.vw_fact_store_revenue`        |

---

