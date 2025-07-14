
# 🏬 Retail Data Warehouse Project (SQL Server + Power BI)

An end-to-end Data Warehouse project designed for a realistic retail business scenario. Built using SQL Server 2022 and Power BI, this project demonstrates modern data warehousing concepts using a layered architecture with ChatGPT-generated sales, product, inventory, and customer data.

---

## 🚀 Project Objectives

- Design and implement a modern data warehouse from scratch
- Apply staging → clean → business-layer architecture
- Use SQL Server and T-SQL for data loading and transformation
- Create a Power BI dashboard for reporting and insights

---

## 🧱 Architecture

CSV Data (Raw) <br>
    ↓  <br>
[ Staging Tables (stg_) ]         → Bronze Layer <br>
    ↓ <br>
[ Clean Tables (int_) ]           → Silver Layer <br>
    ↓  <br>
[ Fact & Dimension Tables (dim_) ] → Gold Layer <br>
    ↓  <br>
[ Power BI Dashboard ]            → Visualization Layer <br>



- **Staging (stg_)**: Raw data loaded from CSV files
- **Clean/Intermediate (int_)**: Transformed, joined, cleaned data
- **Business Layer (dw_)**: Fact and dimension tables for reporting
- **Power BI**: Final dashboard with KPIs and analytics

---

## 📦 Dataset Overview

The data is generated using Faker and NumPy to simulate realistic transactions, products, and customer activity. All data is stored in CSV format inside the `datasets/` folder.

| Table Name     | Type        | Description                             |
|----------------|-------------|-----------------------------------------|
| customers.csv  | Dimension   | Customer info, region, signup date      |
| products.csv   | Dimension   | Product catalog with price & category   |
| stores.csv     | Dimension   | Store info and manager details          |
| calendar.csv   | Dimension   | Dates, months, holidays, etc.           |
| inventory.csv  | Fact        | Inventory levels over time              |
| sales.csv      | Fact        | Retail sales transactions               |

---

## 🛠 Tools & Tech Stack

- **SQL Server 2022**        – Data warehouse engine
- **SSMS**                   – SQL development & debugging
- **Power BI**               – Dashboard and reporting
- **Git/GitHub**             – Version control

---

## 📁 Project Structure
```

retail-data-warehouse-sql/
|
├── Datasets/                               # CSV files for staging
|
├── Script.sql
|   |
│   ├── [Bronze Layer] Staging/             # Create & load raw tables
│   |   
|   ├── [Silver Layer] Transformations/     # Data cleaning and joins
|   |
│   └── [Gold Layer] Reporting/             # Create fact & dimension tables
|
├── Power BI/                                # PBIX file and screenshots
|
├── Diagrams/                               # ERD and architecture visuals
|
|── README.md                               # You're here!
|
└── LICENSE                                 # MIT License

```

---

## 📊 Power BI Dashboard

> Coming soon: Visual report to highlight insights like:

- Top-selling products
- Sales trends by region
- Inventory vs. sales KPIs
- Customer behavior over time

---

## 🙏 Acknowledgements

This project is **inspired by [@DataWithBaraa](https://github.com/DataWithBaraa)** for the clear architectural approach to building modern data warehouses.

The dataset and transformations have been customized to create a unique project for educational and portfolio purposes.

---

## 📌 How to Run This Project

1. Clone this repo  
2. Create a database in SQL Server:
3. CREATE DATABASE RetailDW;
4. Execute scripts from /sql/staging/ to create and load tables
5. Execute scripts from /sql/staging/ to create and load tables
6. Run transformations from /sql/transformations/
7. Build fact/dim tables from /sql/reporting/
8. Open Power BI and connect to the final database layer

---

## 📬 Contact
If you'd like to collaborate or ask questions:


[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/vikas-malakar-5a9446354)


🪪 License
This project is open-source and licensed under the MIT License.
