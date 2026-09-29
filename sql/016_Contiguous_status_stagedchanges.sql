WITH  CTE_baseQuery AS 
(SELECT 
	date_value,
	state
FROM dbo.tasks)

, CTE_Fingerprint AS (
SELECT 
	date_value,
	state,
	CASE 
		WHEN LAG(state, 1, 1) OVER (ORDER BY date_value ASC) = state THEN 0
		ELSE 1
	END AS fingerprint
FROM CTE_baseQuery
)

,CTE_Aggregation AS (
SELECT *, SUM(fingerprint) OVER (ORDER BY date_value ASC) GroupId
FROM CTE_Fingerprint
)

, CTE_FinalQuery AS (
SELECT 
	GroupId,
	state,
	date_value startDate,
	LAST_VALUE(date_value) OVER (PARTITION BY GroupId ORDER BY date_value ASC
									ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) endDate,
	ROW_NUMBER() OVER (PARTITION BY GroupId ORDER BY date_value ASC) rn
FROM CTE_Aggregation
)


SELECT *
FROM CTE_FinalQuery
WHERE rn = 1

/*

DDL Script :

create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success')

*/