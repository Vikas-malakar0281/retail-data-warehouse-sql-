# 🗂️ Choose Data Management Approach

## 📦 Type of Data Architecture

In the world of modern data systems, several architectural paradigms are used to manage data efficiently:

- **Data Warehouse** – Centralized, structured storage optimized for reporting and analytics  
- **Data Lake** – Scalable storage for raw, semi-structured, and unstructured data  
- **Data Lakehouse** – Hybrid solution blending warehouse performance with lake flexibility  
- **Data Mesh** – Domain-oriented, decentralized architecture encouraging data product ownership

✅ **Selected Architecture for this Project:**  
We are building a **traditional Data Warehouse**, best suited for our **structured retail dataset** and focused **analytical use cases**.

---

## 🧱 Approach to Building the Data Warehouse

There are several established methodologies for data warehouse design and implementation:

- **Inmon Approach** – Top-down design using normalized schemas  
- **Kimball Approach** – Bottom-up, dimensional modeling (star/snowflake schemas)  
- **Data Vault** – Highly normalized, scalable method for historical tracking  
- **Medallion Architecture** – Layered approach using Bronze, Silver, and Gold stages

✅ **Selected Methodology:**  
We are implementing the **Medallion Architecture**, which organizes the pipeline into clearly defined, purpose-driven layers:

### 🥉 Bronze Layer (Raw Ingestion)
- Tables: `bronze.csv_customers`, `bronze.csv_products`, `bronze.csv_sales`, `bronze.csv_inventory`, `bronze.csv_stores`, `bronze.csv_calendar`
- Purpose: Ingest raw data from CSVs without transformation or cleansing

### 🥈 Silver Layer (Cleaned & Standardized)
- Tables: `silver.csv_customers`, `silver.csv_products`, `silver.csv_sales`, `silver.csv_inventory`, `silver.csv_stores`, `silver.csv_calendar`
- Purpose: Apply data cleaning, enrichment, and deduplication to prepare for analysis

### 🥇 Gold Layer (Business & Analytical Layer)
- Views: 
  - Fact Views: `vw_fact_sales_summary`, `vw_fact_store_revenue`, `vw_fact_inventory_snapshot`, `vw_fact_product_performance`, `vw_fact_category_performance`, `vw_fact_store_category_performance`, `vw_fact_customer_monthly_summary`
  - Dimension Views: `vw_dim_product`, `vw_dim_customer_value`
- Purpose: Provide business-aligned, consumable datasets for reporting and visualization in Power BI

---

## 🎯 Why This Approach Works

By using the **Medallion Architecture** layered on a traditional data warehouse, we achieve:

- ✅ Clear separation of ingestion, transformation, and reporting
- 🧹 Reliable and maintainable data pipelines
- 📊 Business-ready analytics through dimensional modeling
- 🔄 Easy extensibility for future data sources and transformations
