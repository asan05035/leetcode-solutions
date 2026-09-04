

-- Way_1: Flagging consecuive days record + 
-- flag/SUM/COUNT down to diff/MIN
/*
======================================================
Part_1: Focusing only on records with consective days
=======================================================
*/

WITH base_query AS 
/*
-------------------------------------------------------------
Base query: Retreieving all the columns needed from the tabel
--------------------------------------------------------------
*/
(SELECT 
	CITY AS city,
	DAYS AS event_date,
	CASES AS no_of_cases
FROM complex.covid)

, Aggregation AS 
(
/*
-------------------------------------------------------------
Aggregation: flagging the records with not consective days
--------------------------------------------------------------
*/
SELECT 
	city,
	event_date,
	LEAD(event_date, 1) OVER (PARTITION BY city ORDER BY event_date ASC) next_day,
	-- COUNT(event_date) - 1 AS estimated_consecutive_days
	CASE 
		WHEN DATEADD(DAY, 1, event_date) = LEAD(event_date, 1) OVER (PARTITION BY city ORDER BY event_date ASC)
			THEN 1
		ELSE 0
	END flag
FROM base_query)

, city_with_consecutive_days AS (

/*
-------------------------------------------------------------
city_with_consecutive_days : Retreieving only city with records which has consecutive days
--------------------------------------------------------------
*/
SELECT city
FROM 
(SELECT 
	city,
	COUNT(event_date) - 1 AS estimated_consecutive_days,
	SUM(flag) AS actual_consecutive_days,
	COUNT(*) AS total_days
FROM Aggregation
GROUP BY city) t
WHERE estimated_consecutive_days = actual_consecutive_days
AND total_days > 1)


-- Filtering city with consecutive days
, Cleaned_records AS (SELECT 
	CITY AS city ,
	DAYS AS event_date,
	CASES AS no_of_cases
FROM complex.covid
WHERE city IN (SELECT city 
FROM city_with_consecutive_days))


, city_grouped AS 
(SELECT 
	city,
	LEAD(no_of_cases, 1) OVER (PARTITION BY city ORDER BY event_date ASC) - no_of_cases AS diff
FROM Cleaned_records
--GROUP BY city
)

SELECT 
	city
FROM city_grouped
GROUP BY city
HAVING MIN(diff) > 0


-- Way_1: Flagging consecuive days record + 
-- diff/MIN don to flag/SUM/COUNT 

/*
======================================================
Part_1: Focusing only on records with consective days
=======================================================
*/

WITH base_query AS 
/*
-------------------------------------------------------------
Base query: Retreieving all the columns needed from the tabel
--------------------------------------------------------------
*/
(SELECT 
	CITY AS city,
	DAYS AS event_date,
	CASES AS no_of_cases
FROM complex.covid)

, Aggregation AS 
(
/*
-------------------------------------------------------------
Aggregation: flagging the records with not consective days
--------------------------------------------------------------
*/
SELECT 
	city,
	event_date,
	LEAD(event_date, 1) OVER (PARTITION BY city ORDER BY event_date ASC) next_day,
	-- COUNT(event_date) - 1 AS estimated_consecutive_days
	CASE 
		WHEN DATEADD(DAY, 1, event_date) = LEAD(event_date, 1) OVER (PARTITION BY city ORDER BY event_date ASC)
			THEN 1
		ELSE 0
	END flag
FROM base_query)

, city_with_consecutive_days AS (

/*
-------------------------------------------------------------
city_with_consecutive_days : Retreieving only city with records which has consecutive days
--------------------------------------------------------------
*/
SELECT city
FROM 
(SELECT 
	city,
	COUNT(event_date) - 1 AS estimated_consecutive_days,
	SUM(flag) AS actual_consecutive_days,
	COUNT(*) AS total_days
FROM Aggregation
GROUP BY city) t
WHERE estimated_consecutive_days = actual_consecutive_days
AND total_days > 1)


-- Filtering city with consecutive days
, Cleaned_records AS (SELECT 
	CITY AS city ,
	DAYS AS event_date,
	CASES AS no_of_cases
FROM complex.covid
WHERE city IN (SELECT city 
FROM city_with_consecutive_days))

, flagged_data AS (
SELECT 
	city,
	no_of_cases,
	LEAD(no_of_cases, 1) OVER (PARTITION BY city ORDER BY event_date ASC) next_day_cases,
	CASE --flagging if there is increasing in cases next day
		WHEN 
			LEAD(no_of_cases, 1) OVER (PARTITION BY city ORDER BY event_date ASC) - no_of_cases > 0 THEN 1
			ELSE 0
	END flag
FROM Cleaned_records)

SELECT 
	t.city
FROM(	SELECT 
		city,
		SUM(flag) binary_flag,
		COUNT(*) - 1 count_flag
	FROM flagged_data
	GROUP BY city
	HAVING SUM(flag) = COUNT(*) - 1) AS t

