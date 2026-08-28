/* 
======================================
Question: Find the second most recent activity 
-- if there is no second activity pick the most recent one
======================================
*/

-- =========
-- Init Database
-- =========

/* 
create table cx_17_UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);

insert into cx_17_UserActivity values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');

*/

WITH base_query AS (
-- ==============================
-- 1. Base query: Retrive all columns from the tabel
-- ==============================
SELECT 
	username,
	activity,
	startDate,
	endDate
FROM dbo.cx_17_UserActivity)

, Aggregation AS 
-- ===========================
-- Step 2: attaching row number to his activity and calculation the total activites by each person
-- ===========================
(SELECT 
	username,
	activity,
	startDate,
	endDate,
	ROW_NUMBER() OVER (PARTITION BY username ORDER BY endDate DESC, startDate DESC) activity_row,
	COUNT(activity) OVER (PARTITION BY username) TotalActivities
FROM base_query  )

, final_query AS (
SELECT 
-- =========================
-- Step 3: If a person do more than 1 activity then picking 2nd or else first one
-- Manipulating in WHERE Filter case when
-- =========================
	username,
	activity,
	startDate,
	endDate,
	activity_row,
	TotalActivities
FROM Aggregation
WHERE activity_row = (CASE 
						WHEN TotalActivities >= 2 THEN 2 ELSE 1
					END)
					)

SELECT 
	username,
	activity
FROM final_query

