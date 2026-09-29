/*
====================
Find the 3rd highest salry in each departments
incase the employee have less than 3 employee then picj the employee with lowest salary
=================
*/

-- Way_1 NESTED IF

WITH base_query AS
(
-- ===========================================
-- Base_query: Retreuve the only columns needed
-- ==========================================
SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary
FROM emp
)


,Aggregation AS 
(
-- ===========================================
-- AGggregation: Applying the rank and counting the employee in each department
-- ==========================================
SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	DENSE_RANK() OVER (PARTITION BY dep_name ORDER BY salary DESC) rn,
	--MIN(salary) OVER (PARTITION BY dep_name) min
	COUNT(*) OVER (PARTITION BY dep_name) total_count
FROM base_query
)

, final_query AS
(-- ===========================================
-- Final_query : using nested if to create binary flag 
-- ==========================================
SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	rn,
	--MIN(salary) OVER (PARTITION BY dep_name) min
	total_count,
	CASE
		WHEN total_count < 3 THEN -- IF
			CASE
				WHEN salary = MIN(salary) OVER (PARTITION BY dep_name) THEN 1 --IF
				ELSE 0														-- ELSE
			END
		ELSE						-- ELSE
			CASE 
				WHEN rn = 3 THEN 1
				ELSE 0
			END
	END AS flag
FROM Aggregation
)

SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	rn,
	total_count,
	flag
FROM final_query
WHERE flag = 1










/*=============================================
way_2: USING else_if
==============================================*/


WITH base_query AS
(
-- ===========================================
-- Base_query: Retreuve the only columns needed
-- ==========================================
SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary
FROM emp
)


,Aggregation AS 
(
-- ===========================================
-- AGggregation: Applying the rank and counting the employee in each department
-- ==========================================
SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	DENSE_RANK() OVER (PARTITION BY dep_name ORDER BY salary DESC) rn,
	--MIN(salary) OVER (PARTITION BY dep_name) min
	COUNT(*) OVER (PARTITION BY dep_name) total_count
FROM base_query
)

, final_query AS
(
-- ===========================================
-- Final_query : using nested if to create binary flag 
-- ==========================================

SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	rn,
	--MIN(salary) OVER (PARTITION BY dep_name) min
	total_count,
	CASE
		WHEN total_count < 3 AND salary = MIN(salary) OVER (PARTITION BY dep_name) THEN 1
		WHEN total_count > 2 AND rn = 3 THEN 1
		ELSE 0
	END AS flag
FROM Aggregation
)


SELECT 
	emp_id,
	emp_name,
	dep_name,
	salary,
	rn,
	total_count,
	CASE
		WHEN total_count < 3 AND salary = MIN(salary) OVER (PARTITION BY dep_name) THEN 1 --IF
		WHEN total_count > 2 AND rn = 3 THEN 1											  -- ELIF
		ELSE 0																			  -- ELSE
	END AS flag
FROM final_query
WHERE flag = 1


/*

CREATE TABLE [emp](
 [emp_id] [int] NULL,
 [emp_name] [varchar](50) NULL,
 [salary] [int] NULL,
 [manager_id] [int] NULL,
 [emp_age] [int] NULL,
 [dep_id] [int] NULL,
 [dep_name] [varchar](20) NULL,
 [gender] [varchar](10) NULL
) ;

INSERT INTO emp
VALUES
(1,'Ankit',14300,4,39,100,'Analytics','Female'),
(2,'Mohit',14000,5,48,200,'IT','Male'),
(3,'Vikas',12100,4,37,100,'Analytics','Female'),
(4,'Rohit',7260,2,16,100,'Analytics','Female'),
(5,'Mudit',15000,6,55,200,'IT','Male'),
(6,'Agam',15600,2,14,200,'IT','Male'),
(7,'Sanjay',12000,2,13,200,'IT','Male'),
(8,'Ashish',7200,2,12,200,'IT','Male'),
(9,'Mukesh',7000,6,51,300,'HR','Male'),
(10,'Rakesh',8000,6,50,300,'HR','Male'),
(11,'Akhil',4000,1,31,500,'Ops','Male')
*/