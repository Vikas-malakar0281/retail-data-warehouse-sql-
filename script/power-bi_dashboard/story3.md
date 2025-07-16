# Story 3: Inventory & Stock Levels Dashboard

## Requirement

- Total Products Out of Stock

```sql
 SELECT COUNT(*) AS out_of_stock_products
FROM gold.vw_fact_inventory_snapshot
WHERE stock_status = 'Out of Stock';
```

![{1F37D846-1214-473E-BC48-8EC47BFB44A3}.png](attachment:1c7bfad3-b680-4fda-b274-2b44afe704a2:1F37D846-1214-473E-BC48-8EC47BFB44A3.png)

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

![{2A7C2A7A-4BDC-46C7-9C09-E2B9A5AC8504}.png](attachment:64795717-abc3-4f31-9d22-367b46713d9e:2A7C2A7A-4BDC-46C7-9C09-E2B9A5AC8504.png)

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

![{B0578FE2-B361-42C8-BB52-74285DCDBAF8}.png](attachment:d3bdde43-b260-43da-ba10-581e075be49d:B0578FE2-B361-42C8-BB52-74285DCDBAF8.png)

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

![{18CB8425-F1B2-4A8C-8DE9-45EABBCBB574}.png](attachment:3e5426bf-1b93-427a-b73b-db1ba93015ae:18CB8425-F1B2-4A8C-8DE9-45EABBCBB574.png)

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

![{1C7598FE-A8B6-4611-B254-07E463246E91}.png](attachment:0ac3ca8a-76e1-432c-9a1d-5db695e88303:1C7598FE-A8B6-4611-B254-07E463246E91.png)
