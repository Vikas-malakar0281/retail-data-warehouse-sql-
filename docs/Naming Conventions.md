# 🧾 Naming Conventions

This document outlines the naming conventions used across schemas, tables, views, columns, and stored procedures in the **Retail Data Warehouse** project. Consistent naming ensures maintainability, readability, and alignment across the data pipeline.

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

- **Naming style:** Use `snake_case` (lowercase with underscores).
- **Language:** All object names must be in **English**.
- **Avoid reserved words:** Never use SQL reserved keywords as identifiers.
- **Consistency:** Naming should reflect the layer and business context.

---

## 🗂 Table Naming Conventions

### 🥉 Bronze Layer (Raw Staging)

- **Pattern:** `<source>_<entity>`
- **Rules:**
  - Start with the **source system** name.
  - Keep the **original table/entity name** from source (no renaming).
- **Examples:**
  - `crm_customer_info` → Raw customer info from CRM system
  - `pos_sales_data` → Raw sales data from Point-of-Sale

---

### 🥈 Silver Layer (Cleaned/Transformed)

- **Pattern:** `<source>_<entity>`
- **Rules:**
  - Retain the source prefix.
  - Tables reflect cleaned, deduplicated, or joined data.
- **Examples:**
  - `crm_customer_info` → Deduplicated and cleaned customer data
  - `erp_product_catalog` → Transformed product catalog from ERP

---

### 🥇 Gold Layer (Business Layer - Fact & Dimension)

- **Pattern:** `<category>_<entity>`
- **Rules:**
  - Use business-aligned terms.
  - Prefix indicates table type: `dim_`, `fact_`, `report_`, etc.
- **Examples:**
  - `dim_customer` → Dimension table for customer master
  - `fact_sales` → Fact table for sales transactions
  - `report_sales_monthly` → Reporting table with aggregated monthly sales

---

### 🧾 Glossary of Category Prefixes

| Prefix     | Description            | Example                 |
|------------|------------------------|-------------------------|
| `dim_`     | Dimension table         | `dim_product`, `dim_store` |
| `fact_`    | Fact table              | `fact_inventory`, `fact_sales` |
| `report_`  | Reporting table         | `report_customers`, `report_sales_daily` |

---

## 🔑 Column Naming Conventions

### 🔹 Surrogate Keys

- **Pattern:** `<table>_key`
- **Use:** For primary keys in dimension tables.
- **Example:** `customer_key` in `dim_customer`

### ⚙️ Technical Columns

- **Pattern:** `dwh_<column_name>`
- **Use:** For metadata columns (e.g., load date, record versioning).
- **Examples:**
  - `dwh_load_date` → Date the record was loaded into the DWH
  - `dwh_insert_user` → User or job that inserted the record

---

## 🛠 Stored Procedures

- **Pattern:** `load_<layer>`
- **Use:** For ETL stored procedures related to each DWH layer.
- **Examples:**
  - `load_bronze` → Procedure to load data into Bronze layer
  - `load_silver` → Procedure to transform and load into Silver layer
  - `load_gold` → Procedure to load data into fact and dimension tables

---

### ✅ Summary

Using structured naming conventions improves:
- Clarity for developers and analysts
- Ease of documentation
- Onboarding for new team members
- Automated pipeline management and testing
