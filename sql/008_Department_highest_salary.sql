/*--------------------------------
SELECT *
FROM dbo.Employee;

SELECT *
FROM dbo.Department;
*/-------------------------------


WITH CTE_base_query AS(
/*----------------------------------
Base_query: retrive all colums from the tabel
--------------------------------------*/
SELECT 
	e.id,
	e.name AS name,
	e.salary,
	--e.departmentId,
	d.name AS department_name
FROM dbo.Employee AS e
LEFT JOIN dbo.Department AS d
ON e.departmentId = d.id
)

, CTE_Rank_salary AS (
/* -------------------------------------------
Ranking salary 
------------------------------------------*/
SELECT 
	id,
	name,
	salary,
	department_name,
	RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS rank_salary
FROM CTE_base_query
-- GROUP BY id, name

/*----------------
with groupy + max() i can only pick the max_salary alone 
cannot use group by dept adn name which will create bigger window
-------------------*/
)

SELECT 
	--id,
	department_name,
	name,
	salary
	--rank_salary
FROM CTE_Rank_salary
WHERE rank_salary = 1

/* -------------------------
Function useds : rank(), 
Joins: left-join
Filtering: where
----------------------------------*/


