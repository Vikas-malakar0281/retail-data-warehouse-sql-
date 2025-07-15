# 🧱 ETL Design Layer – Medallion Architecture

This project implements a three-tier **Medallion Architecture** to structure the ETL pipeline into logical layers: **Bronze**, **Silver**, and **Gold**. Each layer transforms the data step-by-step—from raw input to business-ready analytical outputs.

---

| Category              | 🥉 **Bronze Layer**                                         | 🥈 **Silver Layer**                                                   | 🥇 **Gold Layer**                                                                 |
|-----------------------|-------------------------------------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| **Definition**         | Raw data staging from source CSVs                          | Cleaned and enriched datasets ready for modeling                      | Final reporting layer using dimensional modeling and aggregations                |
| **Purpose**            | Enable traceability and fast ingestion                     | Ensure quality, consistency, and transformation logic                 | Serve business needs via analytical fact and dimension views                    |
| **Object Type**        | Tables (`csv_<entity>`)                                    | Tables (`csv_<entity>`)                                               | Views (`vw_fact_<entity>`, `vw_dim_<entity>`)                                   |
| **Load Method**        | Full load using `TRUNCATE` + `INSERT`                      | Full load using `TRUNCATE` + `INSERT`                                 | Views dynamically reference Silver layer (no physical loading)                  |
| **Transformations**    | None (raw as-is)                                           | - Data cleaning<br>- Null handling<br>- Type formatting<br>- Enrichment<br>- Derived columns (profit margin, email domain, etc.) | - Aggregations<br>- Business logic<br>- Time-based metrics<br>- Dimensional joins |
| **Modeling Approach**  | None                                                       | No strict schema—intermediate layer                                   | Star schema: facts + dimensions (denormalized for BI performance)               |
| **Target Users**       | Data Engineers                                             | Data Engineers, Data Analysts                                         | Business Analysts, BI Tools (Power BI), Reporting Teams                         |

---

## 🔁 Layer Flow

```text
📁 CSV Files (Raw)
    ↓
🥉 Bronze Layer — Raw Staging Tables (e.g., csv_sales, csv_customers)
    ↓
🥈 Silver Layer — Cleaned & Transformed Tables (e.g., csv_sales, csv_customers)
    ↓
🥇 Gold Layer — Analytical Views (e.g., vw_fact_sales_summary, vw_dim_product)
    ↓
📊 Power BI Dashboards / SQL Reporting Queries
