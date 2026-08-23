
--- Find Each Employee's Most Visited Floor and Resources Used

WITH CTE_total_visits AS (
SELECT 
	e.name,
	COUNT(*) AS total_visits
FROM dbo.entries AS e
GROUP BY e.name
)

, CTE_floor_visit_count AS (
SELECT 
	e.name, 
	e.floor,
	COUNT(*) visit_count
FROM dbo.entries AS e
GROUP BY e.name, e.floor
)

, CTE_most_visited_floor AS (
-- Main query 
-- for most_visited_floor by each_person
SELECT
	name, floor
FROM (-- Subquery
		SELECT name, 
				floor,
				visit_count,
			ROW_NUMBER() OVER (PARTITION BY cfvc.name ORDER BY cfvc.visit_count  DESC) visit_count_order
		FROM CTE_floor_visit_count AS cfvc) t
WHERE visit_count_order = 1
)


,CTE_resources_used AS (

SELECT 
	t.name AS name,
	STRING_AGG(t.resources, ', ') WITHIN GROUP (ORDER BY resources ASC) AS resourcses_used
FROM ( -- Subquery for getting distinct resources
SELECT 
	DISTINCT e.name,
	-- STRING_AGG(DISTINCT e.resourcses, ', ') WITHIN GROUP (ORDER BY resources ASC) AS resourcses_used
	 e.resources
FROM dbo.entries AS e) t
GROUP BY t.name
)

SELECT 
	ctv.name,
	ctv.total_visits,
	cmvf.floor AS most_visited_floor,
	cru.resourcses_used
FROM CTE_total_visits AS ctv
LEFT JOIN CTE_most_visited_floor AS cmvf 
ON ctv.name = cmvf.name
LEFT JOIN CTE_resources_used AS cru
ON ctv.name = cru.name