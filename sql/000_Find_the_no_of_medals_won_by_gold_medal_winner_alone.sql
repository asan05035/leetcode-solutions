/*
CREATE TABLE sql_med_1_events (
ID int,
event varchar(255),
YEAR INt,
GOLD varchar(255),
SILVER varchar(255),
BRONZE varchar(255)
);

truncate table sql_med_1_events;

INSERT INTO sql_med_1_events 
VALUES 
(1,'100m',2016, 'Amthhew Mcgarray','donald','barbara'),
(2,'200m',2016, 'Nichole','Alvaro Eaton','janet Smith'),
(3,'500m',2016, 'Charles','Nichole','Susana'),
(4,'100m',2016, 'Ronald','maria','paula'),
 (5,'200m',2016, 'Alfred','carol','Steven'),
 (6,'500m',2016, 'Nichole','Alfred','Brandon'),
(7,'100m',2016, 'Charles','Dennis','Susana'),
 (8,'200m',2016, 'Thomas','Dawn','catherine'),
(9,'500m',2016, 'Thomas','Dennis','paula'),
(10,'100m',2016, 'Charles','Dennis','Susana'),
(11,'200m',2016, 'jessica','Donald','Stefeney'),
(12,'500m',2016,'Thomas','Steven','Catherine')

*/

/*
SELECT *
FROM dbo.sql_med_1_events
*/

WITH CTE_base_query AS (
/*-----------------------------------
Base query: Splitting the big data into small partition based on a condition 
- Identifying only gold won swimmers
---------------------------------------*/
SELECT 
		person,
		CASE
			WHEN COUNT(DISTINCT t.medal) > 1 THEN 'Multiple'
			ELSE MAX(t.medal)
		END AS medal_category
FROM(---- Subquery
	---  Cleaning events_result_table
SELECT GOLD AS person,
		'gold' AS medal
FROM dbo.sql_med_1_events

UNION ALL

SELECT SILVER AS person,
		'silver' AS medal
FROM dbo.sql_med_1_events

UNION ALL


SELECT BRONZE AS person,
		'bronze' AS medal
FROM dbo.sql_med_1_events)t
GROUP BY person
HAVING CASE
			WHEN COUNT(DISTINCT t.medal) > 1 THEN 'Multiple'
			ELSE MAX(t.medal)
		END = 'gold'
)
/*------------------------------
2. Final_query: Counting the medal by gold medal winner 
-------------------------------*/

SELECT e.gold,
	COUNT(*) no_of_gold
FROM dbo.sql_med_1_events AS e
WHERE e.gold IN (SELECT person FROM CTE_base_query)
GROUP BY e.gold