/*-----------------
   create table sql_14_users
(
user_id integer,
name varchar(20),
join_date date
);
insert into sql_14_users
values (1, 'Jon', CAST('2-14-20' AS date)), 
(2, 'Jane', CAST('2-14-20' AS date)), 
(3, 'Jill', CAST('2-15-20' AS date)), 
(4, 'Josh', CAST('2-15-20' AS date)), 
(5, 'Jean', CAST('2-16-20' AS date)), 
(6, 'Justin', CAST('2-17-20' AS date)),
(7, 'Jeremy', CAST('2-18-20' AS date));

create table sql_14_events
(
user_id integer,
type varchar(10),
access_date date
);

insert into sql_14_events values
(1, 'Pay', CAST('3-1-20' AS date)), 
(2, 'Music', CAST('3-2-20' AS date)), 
(2, 'P', CAST('3-12-20' AS date)),
(3, 'Music', CAST('3-15-20' AS date)), 
(4, 'Music', CAST('3-15-20' AS date)), 
(1, 'P', CAST('3-16-20' AS date)), 
(3, 'P', CAST('3-22-20' AS date));



SELECT *
FROM dbo.sql_14_events;

-------------------*/

WITH CTE_base_query AS (
/*-----------------------------
1. Baswe query: Preparing the table by joing with filer on right table
				- and multiple time joining same table
-----------------------------*/
SELECT 
	u.user_id,
	u.name,
	u.join_date AS sign_up_date,
	e.type AS feature_type,
	e.access_date AS feature_access_date,
	p.type AS prime_subcription,
	p.access_date AS prime_sub_date
FROM dbo.sql_14_users AS u
INNER JOIN dbo.sql_14_events AS e
ON u.user_id = e.user_id AND e.type = 'Music'
LEFT JOIN dbo.sql_14_events AS p
ON u.user_id = p.user_id AND p.type = 'P'
)

, CTE_Aggregation AS 
/*--------------------------------
2. Aggregation: datediff for finding users who opt for amazon prime within 30 days 
---------------------------------*/
(SELECT 
	user_id,
	name,
	sign_up_date,
	feature_type,
	feature_access_date,
	prime_subcription,
	prime_sub_date,
	DATEDIFF(DAY, sign_up_date, prime_sub_date) AS datediff,
	CASE 
		WHEN DATEDIFF(DAY, sign_up_date, prime_sub_date) <= 30 THEN 1
		ELSE 0
	END AS Flag

FROM CTE_base_query)

SELECT 
	ROUND(CAST(SUM(Flag) AS FLOAT) / COUNT(*), 2) AS fractionPercent
FROM CTE_Aggregation