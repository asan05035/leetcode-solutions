-- yearwise count of new cities where business started their operations

/*

SELECT *
FROM business_city

*/

WITH first_ops AS
(SELECT 
/*=======================================
first_ops: Remove the noise from the data for each id
=========================================*/
	business_date,
	city_id,
	ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY business_date ASC) AS rn
FROM business_city
WHERE business_date IS NOT NULL
)

SELECT 
	YEAR(business_date),
	COUNT(*)
FROM first_ops
WHERE rn = 1
GROUP BY YEAR(business_date)

