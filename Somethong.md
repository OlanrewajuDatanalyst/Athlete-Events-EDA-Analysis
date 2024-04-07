
```sql
SELECT 
  FORMAT_DATE("%Y-%m", created_at) AS month_year,
  ROUND((COUNT(DISTINCT order_id)/COUNT(DISTINCT user_id)),2) AS frequencies,
  ROUND((SUM(sale_price)/COUNT(DISTINCT order_id)),2) AS Average_order_value,
  COUNT(DISTINCT user_id) AS total_unique_users
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Complete'
GROUP BY month_year
ORDER BY month_year DESC;
```

## Output:

And here are the results for the firs 10 rows:

month_year | frequencies | AOV | total_unique_users
-- | -- | -- | --
2023-09 | 1.09 | 87.73 | 1327
2023-08 | 1.04 | 82.53 | 2436
2023-07 | 1.02 | 82.09 | 1972
2023-06 | 1.02 | 87.12 | 1588
2023-05 | 1.01 | 85.11 | 1503
2023-04 | 1.01 | 83.77 | 1378
2023-03 | 1.01 | 86.18 | 1290
2023-02 | 1.01 | 83.6 | 1100
2023-01 | 1.0 | 81.93 | 1074
2022-12 | 1.01 | 83.97 | 1037
