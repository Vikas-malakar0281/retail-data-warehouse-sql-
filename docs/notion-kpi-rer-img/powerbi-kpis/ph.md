## Sales Performance

### Requirement

* Total Revenue: Total revenue generated

---

```sql
SELECT SUM(total_sales) Total_revenue FROM gold.vw_fact_sales_summary
```

---

![1.png](retail-data-warehouse-sql-/docs/notion-kpi-rer-img/powerbi-kpis/story1/1.png).
)

---

* Total orders:

```sql
SELECT COUNT(sales_id) AS total_orders FROM gold.vw_fact_sales_transactions;
```

---

![Total Order](docs/notion-kpi-req-img/story1/Total-order.png)

---

* Total Quantity Sold

```sql
SELECT SUM(total_quantity) AS total_quantity_sold FROM gold.vw_fact_sales_summary;
```

---

![Total Quantity Sold](docs/notion-kpi-req-img/story1/49A8268B-00B5-41F5-BC3B-A1F3DC2BECB0.png)

---

* Sales Trend Over Time (Year-Month)

```sql
SELECT year, month, SUM(total_sales) AS monthly_sales 
FROM gold.vw_fact_sales_summary 
GROUP BY year, month 
ORDER BY CAST(CONCAT(month, ' 1, ', year) AS DATE);
```

---

![Sales Trend](docs/notion-kpi-req-img/story1/731DE957-36ED-40C7-B393-AFCD52C5CC5E.png)

---

* Sales by Store (Top-Performing Stores)

```sql
SELECT
    s.store_name,
    SUM(fs.total_sales) AS store_sales
FROM gold.vw_fact_sales_summary fs
JOIN silver.csv_stores s ON fs.store_id = s.store_id
GROUP BY s.store_name
ORDER BY store_sales DESC;
```

---

![Sales by Store](docs/notion-kpi-req-img/story1/2ca8d44c-fd1a-4f37-9416-db7d8f37fdc6.png)

---

* Sales by Product (Top-Performing Products)

```sql
SELECT 
    p.product_name,
    SUM(fs.total_sales) AS product_sales
FROM gold.vw_fact_sales_summary fs
JOIN silver.csv_products p ON fs.product_id = p.product_id
GROUP BY p.product_name
ORDER BY product_sales DESC;
```

---

![Sales by Product](docs/notion-kpi-req-img/story1/9BB86B38-5BC0-43C9-90A0-1C4FE71F76E3.png)

---

* Average Order Value (AOV)

```sql
SELECT 
    SUM(total_price) * 1.0 / COUNT(DISTINCT sales_id) AS avg_order_value
FROM gold.vw_fact_sales_transactions;
```

---

![Average Order Value](docs/notion-kpi-req-img/story1/3463D49B-0BB4-46ED-8EFB-69DE6C692CA2.png)

---

* Top 10 Products by Quantity Sold

```sql
SELECT TOP 10
    p.product_name,
    SUM(fs.total_quantity) AS units_sold
FROM gold.vw_fact_sales_summary fs
JOIN silver.csv_products p ON fs.product_id = p.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;
```

---

![Top 10 Products](docs/notion-kpi-req-img/story1/3389A230-31C8-4FD3-B070-AF86C1C51A0C.png)
