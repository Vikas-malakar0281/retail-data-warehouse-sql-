# Story 3: Inventory & Stock Levels Dashboard

## Requirement

- Total Products Out of Stock

```sql
 SELECT COUNT(*) AS out_of_stock_products
FROM gold.vw_fact_inventory_snapshot
WHERE stock_status = 'Out of Stock';
```

![1.png](story3/1.png)

- **Products by Stock Status**

```sql
sql
CopyEdit
SELECT
    stock_status,
    COUNT(*) AS total_products
FROM gold.vw_fact_inventory_snapshot
GROUP BY stock_status;

```

![2.png](story3/2.png)

- **Top 10 Overstocked Products**

```sql
sql
CopyEdit
SELECT TOP 10
    product_name,
    category,
    store_name,
    stock_level
FROM gold.vw_fact_inventory_snapshot
WHERE stock_status = 'Overstocked'
ORDER BY stock_level DESC;

```

![3.png](story3/3.png)

- **Low Stock or Critical Items**

```sql
sql
CopyEdit
SELECT
    product_name,
    category,
    store_name,
    stock_level
FROM gold.vw_fact_inventory_snapshot
WHERE stock_status IN ('Out of Stock', 'Low Stock')
ORDER BY stock_level ASC;

```

![4.png](story3/4.png)

- **Stock Level by Category**

```sql
sql
CopyEdit
SELECT
    category,
    SUM(stock_level) AS total_stock
FROM gold.vw_fact_inventory_snapshot
GROUP BY category
ORDER BY total_stock DESC;

```

![4.png](story3/4.png)
