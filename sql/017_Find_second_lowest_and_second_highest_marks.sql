-- ====================================================
SELECT 
	subject,
	marks
FROM complex.students

/*
===========================================================
Q3: Find the second lowest and highest mark in each subject
===========================================================
*/


-- ==================================
-- way_1: CTE + inner_join(data filtering)
-- ==================================
WITH cte_ranked AS
(
/*
Aggregation: Raking marks in both desc and ascending ways
*/

SELECT 
	subject,
	marks,
	ROW_NUMBER() OVER (PARTITION BY subject ORDER BY marks DESC) rn_high,
	ROW_NUMBER() OVER (PARTITION BY subject ORDER BY marks ASC) rn_low
FROM complex.students
)

-- ===============================
-- Using inner join for filtering in left table
-- ==============================
SELECT 
	a.subject,
	a.marks AS second_highest,
	b.marks AS second_lowest
FROM  cte_ranked AS a
INNER JOIN cte_ranked AS b
ON a.subject = b.subject
AND b.rn_low = 2
AND a.rn_high = 2

-- ====================================
-- Way_2: mutiple_ctes
-- =====================================

WITH highest_to_lowest AS
(SELECT 
	subject,
	marks,
	ROW_NUMBER() OVER(PARTITION BY subject ORDER BY marks DESC) rn
FROM complex.students
)
,
lowest_to_highest AS
(
SELECT 
	subject,
	marks,
	ROW_NUMBER() OVER(PARTITION BY subject ORDER BY marks ASC) rn
FROM complex.students
)
,CTE_table_a AS
(SELECT 
	subject,
	marks
FROM highest_to_lowest
WHERE rn = 2
)
, CTE_table_b AS
(
SELECT 
	subject,
	marks
FROM lowest_to_highest
WHERE rn = 2
)

SELECT
	a.subject,
	a.marks AS second_highest,
	b.marks AS second_lowest
FROM CTE_table_a AS a
LEFT JOIN CTE_table_b AS b
ON a.subject = b.subject

-- =========================================