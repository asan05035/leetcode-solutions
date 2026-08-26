-- Method_3 (Best Apporoach):
-- Finding the missing quarter by aggregation
-- since quarter is hierarchical data structure

WITH CTE_quarter AS (
-- ========================================
-- Generating store with quarter using Recursive cte
-- =========================================

-- Anchor Query
SELECT DISTINCT s.store AS StoreName, 1 AS Quarter FROM dbo.cx_21_STORES AS s

UNION ALL 
-- Recursive Query
SELECT 
	q.StoreName, q.Quarter + 1 
FROM CTE_quarter AS q
WHERE quarter < 4
)

, StoresWithQuarters AS 
(
-- =======================================
-- 2. Aggreation: Casting int to string 
-- =======================================
SELECT 
	StoreName,
	'Q' + CAST(Quarter AS VARCHAR(10)) Quarter
FROM CTE_quarter
)

, FinalQuery AS 
(
-- ==============================
-- 2. Final_query: combining all queries output to one query
-- ================================
SELECT
	sq.StoreName,
	sq.Quarter,
	s.amount
FROM StoresWithQuarters AS sq
LEFT JOIN dbo.cx_21_STORES AS s
ON sq.StoreName = s.store AND sq.Quarter = s.quarter
WHERE s.amount IS NULL )

SELECT 
	StoreName,
	Quarter
FROM FinalQuery