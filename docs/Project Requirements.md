# 📋 Project Requirements

## 🏗️ Building the Data Warehouse (SQL)

### 🎯 Objective

Design and implement a robust **Retail Data Warehouse** using **SQL Server 2022** to consolidate and model sales, customer, inventory, product, and store data. The goal is to enable scalable, consistent, and high-quality analytics for business reporting.

---

### 📌 Specifications

- **📁 Data Source:**  
  The dataset is generated by **ChatGPT** to mimic realistic retail operations, including files for:
  - `customers.csv`
  - `products.csv`
  - `sales.csv`
  - `stores.csv`
  - `inventory.csv`
  - `calendar.csv`

- **🏗️ Architecture Used:**  
  The project follows the **Medallion Architecture**, consisting of three layers:
  - 🥉 `bronze` – raw CSV ingestion  
  - 🥈 `silver` – cleaned and transformed tables  
  - 🥇 `gold` – business-ready analytical views (fact and dimension views)

- **🧹 Data Quality Rules:**  
  Data cleaning is performed in the **silver layer**, including:
  - Deduplication
  - Null handling and validation
  - Phone and email normalization
  - Profit margin & pricing standardization

- **📐 Data Modeling:**  
  The **gold layer** follows a **star schema** structure with:
  - Dimension Views: `vw_dim_customer_value`, `vw_dim_product`  
  - Fact Views: `vw_fact_sales_summary`, `vw_fact_store_revenue`, `vw_fact_inventory_snapshot`, `vw_fact_product_performance`, `vw_fact_customer_monthly_summary`, etc.

- **📅 Scope:**  
  This version focuses on **snapshot-based analysis** of the latest data. Historical tracking and SCD (Slowly Changing Dimensions) are **not included** in this phase.

- **📝 Deliverables:**  
  Project deliverables include:
  - SQL Scripts with inline comments  
  - Entity-relationship and model diagrams  
  - Layered data flow  
  - GitHub documentation (README, requirements, naming conventions, approach)  
  - Power BI visualizations for final presentation

---

## 📊 BI: Analytical & Reporting (Data Analysis)

### 🎯 Objective

Enable **insightful business analysis** using SQL queries and Power BI dashboards for:

- **🧍 Customer Behavior** – first/last purchase, order frequency, total spending  
- **🛍️ Product Performance** – bestsellers, high-margin categories, sales trends  
- **📈 Sales Trends** – monthly store performance, revenue by region, discount impacts  
- **🏬 Store Insights** – store type performance, inventory patterns, customer distribution

These insights empower stakeholders to make **data-informed decisions** based on real-time retail metrics.

