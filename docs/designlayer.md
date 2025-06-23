# 🧱 ETL Design Layer – Medallion Architecture

This project implements a three-tier **Medallion Architecture** to structure the ETL pipeline into logical layers: **Bronze**, **Silver**, and **Gold**. Each layer serves a specific purpose in the transformation of raw data into business-ready insights.

---

| Category            | 🥉 **Bronze Layer**                                 | 🥈 **Silver Layer**                                         | 🥇 **Gold Layer**                                                     |
|---------------------|-----------------------------------------------------|-------------------------------------------------------------|------------------------------------------------------------------------|
| **Definition**       | Extracting original data from source CSV files     | Transforming raw data into quality datasets                 | Business-ready data with indexes, rules, and derived logic            |
| **Objective**        | Traceability & Debugging                           | Prepare data for analysis                                   | Provide data for reporting and analytics                              |
| **Objective Type**   | Tables                                              | Tables                                                      | Views                                                                 |
| **Load Method**      | Full Load (`TRUNCATE` & `INSERT`)                  | Full Load (`TRUNCATE` & `INSERT`)                           | None (views reference silver layer)                                   |
| **Data Transformation** | As-is                                           | - Data Cleaning<br>- Data Standardization<br>- Data Normalization<br>- Derived Columns<br>- Data Enrichment | - Data Integration<br>- Data Aggregation<br>- Business Logic & Rules |
| **Data Modeling**    | As-is                                               | As-is                                                       | - Star Schema<br>- Aggregated Objects<br>- Flat Tables                |
| **Target Audience**  | Data Engineers                                      | Data Engineers, Data Analysts                               | Data Analysts                                                         |

---
