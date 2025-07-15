
# 🛠 End-to-End ETL Walkthrough for Retail Data Warehouse

## 📌 Overview

This document outlines the complete ETL (Extract, Transform, Load) process implemented for the **Retail Data Warehouse** using the **Medallion Architecture** with SQL Server 2022:

- 🥉 **Bronze Layer**: Raw data ingestion from CSV files.
- 🥈 **Silver Layer**: Cleaned, transformed, and enriched datasets.
- 🥇 **Gold Layer**: Business-aligned analytical views.

---

## 1️⃣ Bronze Layer – Raw Ingestion

### 🎯 Objective:
Load original CSV files into staging tables under the `bronze` schema for traceability and isolation.

### 📁 Data Source:
`C:\SQL2022\retail-data-warehouse-sql\datasets\`

### ⚙️ Procedure:
- **Stored Procedure:** `bronze.load_bronze`

### 🔍 Highlights:
- Uses `TRUNCATE + BULK INSERT` to ensure clean refreshes.
- Handles quoted fields, line breaks, and encoding issues.
- Ensures raw fidelity—no transformation applied.

### 📄 Tables Loaded:
- `bronze.csv_calendar`
- `bronze.csv_customers`
- `bronze.csv_inventory`
- `bronze.csv_products`
- `bronze.csv_sales`
- `bronze.csv_stores`

---

## 2️⃣ Silver Layer – Cleaned & Enriched

### 🎯 Objective:
Transform bronze layer data into a structured, high-quality intermediate dataset.

### ⚙️ Procedure:
- **Stored Procedure:** `silver.load_proc`
- **Helper View:** `silver.vw_clean_phone` (standardizes phone numbers)

### 🧹 Highlights:
- Cleans phone numbers, email domains, and name fields.
- Adds derived columns: `dwh_profit_margin`, `dwh_price_category`, `dwh_net_price`, etc.
- Identifies `low_stock`, `franchise` status, and parses names.
- Ensures consistent datatypes, formats, and NULL handling.

### 📄 Tables Transformed:
- `silver.csv_calendar`
- `silver.csv_customers`
- `silver.csv_inventory`
- `silver.csv_products`
- `silver.csv_sales`
- `silver.csv_stores`

---

## 3️⃣ Gold Layer – Analytical Views

### 🎯 Objective:
Expose finalized dimensional and fact views optimized for reporting and BI tools.

### 🧱 Naming Conventions:
- `vw_dim_<entity>` → Dimension views
- `vw_fact_<entity>` → Fact views

### 📊 Views Created:
- `gold.vw_dim_date`
- `gold.vw_dim_customer`
- `gold.vw_dim_product`
- `gold.vw_dim_store`
- `gold.vw_fact_sales_summary`
- `gold.vw_fact_inventory_snapshot`
- `gold.vw_fact_customer_monthly_summary`
- `gold.vw_fact_product_performance`

### 🔍 Highlights:
- Built entirely as **views** on Silver layer (no physical tables).
- Uses simplified, denormalized structures.
- Follows star-schema principles for optimal performance in tools like Power BI.

---

## 4️⃣ Indexing Strategy (Performance Tuning)

To improve Gold layer view performance, the following indexes are applied on **Silver layer tables**:

### ✅ Key Indexes:
```sql
-- Sales Fact Optimizations
CREATE NONCLUSTERED INDEX IX_sales_year_month_store_product
ON silver.csv_sales (dwh_sale_by_year, dwh_sale_by_month, store_id, product_id);

CREATE NONCLUSTERED INDEX IX_sales_customer_time
ON silver.csv_sales (customer_id, dwh_sale_by_year, dwh_sale_by_month);

CREATE NONCLUSTERED INDEX IX_sales_product_time
ON silver.csv_sales (product_id, dwh_sale_by_year, dwh_sale_by_month);

-- Calendar Join
CREATE NONCLUSTERED INDEX IX_calendar_date
ON silver.csv_calendar (date);

-- Customer Join
CREATE NONCLUSTERED INDEX IX_customers_id_name
ON silver.csv_customers (customer_id, dwh_full_name);

-- Product Join
CREATE NONCLUSTERED INDEX IX_products_price_category
ON silver.csv_products (dwh_price_category)
INCLUDE (product_id, product_name, category);

-- Store Join
CREATE NONCLUSTERED INDEX IX_stores_franchise
ON silver.csv_stores (dwh_is_franchise)
INCLUDE (store_id, store_name, country);

-- Inventory Performance
CREATE NONCLUSTERED INDEX IX_inventory_product_store_date
ON silver.csv_inventory (product_id, store_id, stock_date);
```

---

## 5️⃣ Execution Flow

```sql
-- 1. Load Raw CSVs into Bronze Layer
EXEC bronze.load_bronze;

-- 2. Clean and Transform Data into Silver Layer
EXEC silver.load_proc;

-- 3. No load required for Gold Layer (views auto-refresh from Silver)
```

---

## 6️⃣ Automation Options

This ETL process can be scheduled using:

- 🔁 **SQL Server Agent** (Windows)
- 🛠 **SSIS Packages** (for workflow-based execution)
- ☁️ **Azure Data Factory** (cloud-based orchestration)

---

## 7️⃣ Future Enhancements

- Add **Change Data Capture (CDC)** or incremental load mechanism.
- Implement **audit logs** for row-level lineage tracking.
- Introduce **Power BI Quality Dashboards** and KPI monitoring.
- Build **data validation alerts** for outliers or missing data.

---

## ✅ Summary

This walkthrough highlights the full ETL pipeline from raw ingestion to final analytical views. The layered architecture ensures:

- ✅ Modular, maintainable SQL pipeline
- 🧱 Structured design for scalability
- ⚡ Optimized performance via indexing
- 📊 Business-aligned reporting layer (Gold)
