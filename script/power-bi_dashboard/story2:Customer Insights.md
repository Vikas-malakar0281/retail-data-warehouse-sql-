# B. Customer Insight

## Requirement

- Top 10 High-Value Customers by Total Spend

```sql
SELECT TOP 10 
    customer_name,
    total_spent
FROM gold.vw_dim_customer_value
ORDER BY total_spent DESC;
```

![{FD9AB09A-B67B-4FBE-BBC9-9DED60FBB9AC}.png](attachment:7748eda6-89f5-40c4-abd6-6f3909f31948:FD9AB09A-B67B-4FBE-BBC9-9DED60FBB9AC.png)

- Customer Frequency (Most Orders)

```sql
SELECT TOP 10 
    customer_name,
    total_orders
FROM gold.vw_dim_customer_value
ORDER BY total_orders DESC;
```

![{E717A360-9DAE-414D-8049-CB1BD2909A60}.png](attachment:7df50dcc-c763-4ba4-8022-33ca15d2af74:E717A360-9DAE-414D-8049-CB1BD2909A60.png)

- Monthly Purchase Trend by Customer

```sql
SELECT 
    year,
    month,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(total_spent) AS total_monthly_spend
FROM gold.vw_fact_customer_monthly_summary
GROUP BY year, month
ORDER BY 
    CAST(CONCAT(month, ' 1, ', year) AS DATE);
```

![{9DD747F7-1D97-45B5-80BE-24B56273DB1C}.png](attachment:70f0ae85-9435-471b-8e50-f0418c1d9a72:9DD747F7-1D97-45B5-80BE-24B56273DB1C.png)

- Average Order Value by Customer Segment

```sql
SELECT 
    customer_name,
    ROUND(total_spent * 1.0 / NULLIF(total_orders, 0), 2) AS avg_order_value
FROM gold.vw_dim_customer_value
ORDER BY avg_order_value DESC;
```

![{4066BBEA-A9FC-4688-87D7-58938D740CE7}.png](attachment:f2f2de1f-ccd1-4c64-90f4-0afaa5702629:4066BBEA-A9FC-4688-87D7-58938D740CE7.png)

- Seasonal Trend in Customer Purchases

```sql
SELECT 
    month,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_spent) AS total_spending
FROM gold.vw_fact_customer_monthly_summary
GROUP BY month
ORDER BY month;
```

![{73626DB0-8B12-4270-AB2D-5CB2F3BF9785}.png](attachment:8711f9a7-0402-478a-a5af-02575666cb45:73626DB0-8B12-4270-AB2D-5CB2F3BF9785.png)
