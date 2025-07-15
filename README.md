# 🏬 Retail Data Warehouse Project (SQL Server + Power BI)

An end-to-end Data Warehouse project built using **SQL Server 2022** and **Power BI**, simulating a realistic retail scenario. The project demonstrates the use of Medallion Architecture to transform raw sales, customer, product, and inventory data into actionable insights.

---

## 🚀 Project Objectives

* Design a modern data warehouse from scratch
* Apply **Bronze → Silver → Gold** architecture
* Use T-SQL and stored procedures for ETL processes
* Build a Power BI dashboard on top of Gold Layer views

---

## 🛡️ Architecture

```text
CSV Files (Raw)
   ↓
Bronze Layer  — Raw Staging Tables (bronze.csv_*)
   ↓
Silver Layer  — Cleaned & Transformed Tables (silver.csv_*)
   ↓
Gold Layer    — Fact & Dimension Views (gold.fact_*, gold.dim_*)
   ↓
Power BI Dashboard — Visualization Layer
```

* **Bronze Layer**: Ingest raw CSV files into staging tables using `BULK INSERT`
* **Silver Layer**: Clean, deduplicate, and enrich data with derived columns
* **Gold Layer**: Build analytical views with fact and dimension tables
* **Power BI**: Use Gold views to visualize KPIs and business insights

---

## 📦 Dataset Overview

Data is synthetically generated using **Faker** and **NumPy** to simulate real-world customer behavior and transactions. CSV files are located under `/datasets/`.

| Table Name    | Type      | Description                              |
| ------------- | --------- | ---------------------------------------- |
| customers.csv | Dimension | Customer profiles, signup data, region   |
| products.csv  | Dimension | Product info, category, pricing          |
| stores.csv    | Dimension | Store location and type                  |
| calendar.csv  | Dimension | Time intelligence columns                |
| inventory.csv | Fact      | Stock levels for each store-product-date |
| sales.csv     | Fact      | All sales transactions                   |

---

## 🛠️ Tools & Tech Stack

* **SQL Server 2022** — Data warehousing engine
* **SSMS** — Development and debugging
* **Power BI** — Visual reporting
* **GitHub** — Version control and collaboration

---

## 📁 Project Structure

```
retail-data-warehouse-sql/
|
├── datasets/                             # Source CSV files
|
├── scripts/
|   ├── bronze/                           # Staging scripts (load_bronze)
|   ├── silver/                           # Transform & clean scripts (load_proc)
|   └── gold/                             # Fact & dimension views + indexing
|
├── docs/                                 # Project documentation
|
├── powerbi/                              # Dashboard and visuals
|
├── diagrams/                             # ERD and architectural diagrams
|
├── README.md                             # You’re here!
|
└── LICENSE                               # MIT License
```

---

## 📊 Power BI Dashboard

> Coming Soon: Insights with rich visuals powered by Gold Layer views

* Regional and Monthly Sales Trends
* Inventory vs. Sales KPIs
* High Margin Products and Categories
* Customer Segmentation & Behavior

---

## 🙏 Acknowledgements

* Inspired by [@DataWithBaraa](https://github.com/DataWithBaraa)
* All data and transformations are unique and designed for portfolio & educational purposes

---

## 📌 How to Run This Project

1. Clone the repository
2. Create a new database:

   ```sql
   CREATE DATABASE RetailDW;
   ```
3. Execute Bronze scripts to load CSVs:

   ```sql
   EXEC bronze.load_bronze;
   ```
4. Run Silver transformation procedure:

   ```sql
   EXEC silver.load_proc;
   ```
5. Gold views will be auto-refreshed as they are dynamic
6. Open Power BI and connect to SQL views in the `gold` schema

---

## 📩 Contact

Feel free to reach out for collaboration or feedback:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge\&logo=linkedin\&logoColor=white)](https://linkedin.com/in/vikas-malakar-5a9446354)

---

## 🗋ufe0f License

This project is open-source and licensed under the **MIT License**.
