
--- For each day find the new and repeat customers

WITH CTE_first_order_date AS (
SELECT
      customer_id
      ,MIN(order_date) AS first_order_date
FROM dbo.customer_orders
GROUP BY customer_id
)


SELECT 
    order_date,
    SUM(flag) AS new_customers,
    COUNT(*) - SUM(flag) AS repeat_customers
FROM (SELECT o.customer_id,
        o.order_date,
        cfod.first_order_date,
    CASE WHEN order_date = first_order_date THEN 1
         ELSE 0
    END AS flag
FROM dbo.customer_orders AS o
LEFT JOIN CTE_first_order_date AS cfod
ON o.customer_id = cfod.customer_id)t
GROUP BY order_date


SELECT 
order_date, 
COUNT(*) total_customers,
SUM(flag) AS new_customers,
COUNT(*) - SUM(flag) AS repeat_customers,
SUM(order_amount) total_sales,
SUM(CASE WHEN flag = 1 THEN order_amount ELSE 0 END) new_customer_sales,
SUM(CASE WHEN flag != 1 THEN order_amount ELSE 0 END) repeat_customer_sales
FROM (SELECT 
        customer_id,
        order_date,
        order_amount,
        LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS previous_order_date,
        CASE 
            WHEN LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date ASC) IS NULL THEN 1
            ELSE 0
        END AS flag
FROM customer_orders) t
GROUP BY order_date
