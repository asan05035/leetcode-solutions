
/*===========================
Problem statement: Find the total sales by Year (id: cx_sql_11)
===============================*/



/*=====================
-- Init Database
=================*/
CREATE TABLE cx_12_sales (
product_id INT,
period_start DATE,
period_end DATE,
average_daily_sales INT
);

INSERT INTO cx_12_sales 
VALUES
		(1,'2019-01-25','2019-02-28',100),
		(2,'2018-12-01','2020-01-01',10),
		(3,'2019-12-01','2020-01-31',1);


/*=====================================
Method_2: Creating a master file of date record by CTE_recursive
and using it to sale in each day
========================================*/

WITH CTE_recursive AS 
/*======================================
-- Generating Dates record
==========================================*/
(SELECT MIN(c.period_start) StartDate, MAX(c.period_end) EndDate
FROM dbo.cx_12_sales AS c

UNION ALL
SELECT 
	DATEADD(DAY, 1, r.StartDate) StartDate,
	r.EndDate
FROM CTE_recursive AS r
WHERE r.StartDate < r.EndDate)

, base_query AS
(
-- Retrive the columns needed from the recursive cte
SELECT 
	r.StartDate AS Date
FROM CTE_recursive AS r
)


, final_query AS (
/*================================
-- was there a sale in each day of particular product 
-- by  checking if the date is in the product date reord
====================================*/
SELECT 
	s.product_id,
	Date AS saleDate,
	s.average_daily_sales AS avg_sale
FROM base_query AS b
INNER JOIN dbo.cx_12_sales AS s
ON b.Date BETWEEN s.period_start AND s.period_end
)

SELECT 
	product_id,
	YEAR(saleDate) AS Year,
	SUM(avg_sale) AS TotalSales
FROM final_query
GROUP BY product_id, YEAR(saleDate)
OPTION(MAXRECURSION 0);

/*====================================
Method_3: Instead of creating a master file and join 
just work with existing record and create new record from that
================================*/

WITH CTE_recursive AS 
(
SELECT 
	product_id,
	CAST(period_start AS DATE) StartDate,
	CAST(period_end AS DATE) EndDate,
	average_daily_sales
FROM cx_12_sales

UNION ALL 

SELECT 
	product_id,
	DATEADD(DAY, 1, StartDate),
	EndDate,
	average_daily_sales
FROM CTE_recursive AS r
WHERE r.StartDate < r.EndDate
)


SELECT 
	product_id,
	YEAR(StartDate) Year,
	--EndDate,
	SUM(average_daily_sales) totalSales
FROM CTE_recursive
--OPTION (MAXRECURSION 500)
GROUP BY product_id, YEAR(StartDate)
OPTION (MAXRECURSION 0);
