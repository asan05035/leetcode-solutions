-- ====================
-- Sessionizing Sequential Event Logs
-- =====================

WITH CTE_flagged AS 
(SELECT 
/*
=====================================
Flagged : Separating each session by binary flag

=====================================
*/
	event_time, 
	status,
	LAG(status, 1) OVER (ORDER BY event_time ASC) previousStatus,
	CASE 
		WHEN status = 'on' AND LAG(status, 1, 'on') OVER (ORDER BY event_time ASC) = 'off' THEN 1
		WHEN LAG(status, 1) OVER (ORDER BY event_time ASC) IS NULL THEN 1
		ELSE 0
	END groupFlag,
	CASE WHEN status = 'on' THEN 1 ELSE 0 END AS CountFlag
FROM event_status
)

, Aggregation AS (

/*
=====================================
Aggregatioon : Creating groupid or division by binary flag

=====================================
*/
SELECT 
	event_time, 
	status,
	--previousStatus,
	SUM(groupFlag) OVER(ORDER BY event_time ASC) AS groupID,
	CountFlag	
FROM CTE_flagged
)


/*
=====================================
FinalQuery : 
	- using max, min to get the minimum date and maimum date 
		instead of first or last value window function

=====================================
*/
SELECT 
	--groupID,
	MIN(event_time) startTime,
	MAX(event_time) endTime,
	--status,
	SUM(CountFlag) totalOnCount,
	COUNT(*) - SUM(CountFlag) AS totalOffCount
FROM Aggregation
GROUP BY groupID

/*
====================================
DDL Script:
	This script is used to create event_status table
=====================================
*/

create table event_status
(
event_time varchar(10),
status varchar(10)
);
insert into event_status 
values
('10:01','on'),('10:02','on'),('10:03','on'),('10:04','off'),('10:07','on'),('10:08','on'),('10:09','off')
,('10:11','on'),('10:12','off');