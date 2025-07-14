# End-to-End ETL Walkthrough for Retail Data Warehouse

## Overview

This document outlines the full ETL (Extract, Transform, Load) process used to populate the Retail Data Warehouse, implementing the Medallion Architecture:

- **Bronze Layer**: Raw data ingestion from CSV files.
- **Silver Layer**: Cleansed, transformed, and enriched data.
- **Gold Layer**: Business-focused dimensional modeling using SQL views.

---

## 1. Bronze Layer (Raw Ingestion)

### Objective:

Ingest raw CSV files into staging tables under the `bronze` schema.

### Data Source:

CSV files located in: `C:\SQL2022\retail-data-warehouse-sql-\datasets\`

### Procedure:

- **Stored Procedure**: `[bronze].[load_bronze]`

### Highlights:

- Truncates each `bronze` table before loading.
- Loads data using `BULK INSERT`.
- Cleans quoted data (e.g., `stores.csv`) with `FIELDQUOTE` and newline handling.

### Tables Loaded:

- `bronze.csv_calendar`
- `bronze.csv_customers`
- `bronze.csv_inventory`
- `bronze.csv_products`
- `bronze.csv_sales`
- `bronze.csv_stores`

---

## 2. Silver Layer (Cleansed & Enriched)

### Objective:

Transform and enrich raw data, applying business logic, quality fixes, and computed fields.

### Procedure:

- **Stored Procedure**: `[silver].[load_proc]`
- **Helper View**: `[silver].[vw_clean_phone]`

### Highlights:

- Standardizes phone numbers and extensions.
- Extracts full name and email domain.
- Parses `store_name` into base name and franchise info.
- Calculates profit, margin, price tier, etc.
- Classifies inventory stock level.

### Tables Loaded:

- `silver.csv_calendar`
- `silver.csv_customers`
- `silver.csv_inventory`
- `silver.csv_products`
- `silver.csv_sales`
- `silver.csv_stores`

---

## 3. Gold Layer (Business Views)

### Objective:

Expose business-ready dimensional and fact views for reporting and analysis.

### Naming Convention:

- **Fact Tables**: `gold.fact_*`
- **Dimension Tables**: `gold.dim_*`

### Views:

- `gold.dim_date`
- `gold.dim_customer`
- `gold.dim_product`
- `gold.dim_store`
- `gold.fact_sales`
- `gold.fact_inventory`

### Highlights:

- No physical tables, only views built on top of Silver tables.
- Designed for easy integration with BI tools (e.g., Power BI).

---

## 4. Indexing Strategy

Indexes are applied to critical join and filter columns in Silver tables to support Gold views:

- On foreign key columns like `customer_id`, `product_id`, `store_id`.
- On `date` columns in `csv_calendar`, `csv_sales`, and `csv_inventory`.

---

## 5. Execution Flow

1. **Bronze Load**

```sql
EXEC bronze.load_bronze;

```

1. **Silver Load**

```sql
EXEC silver.load_proc;

```

1. **Gold Views are automatically up to date**, since they are dynamic SQL views.

---

## 6. Scheduling Options (Optional)

You may automate ETL using:

- **SQL Server Agent** (Windows Task Scheduler alternative)
- **SSIS Packages** (for graphical workflow)
- **Azure Data Factory** (for cloud pipelines)

---

## 7. Future Enhancements

- Implement **CDC (Change Data Capture)** or **Delta Loads**.
- Add **Audit Logging Table** for each layer.
- Create **Data Quality Scorecards** in Power BI.

---

## Summary

This ETL process follows best practices with:

- Layered architecture
- Clean transformation logic
- Parameter-free stored procedures
- Gold views tailored for analytics
