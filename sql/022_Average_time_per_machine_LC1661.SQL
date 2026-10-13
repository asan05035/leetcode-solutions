WITH base_report AS
(
-- ==============================
-- Base_report: Getting all columns nneded from the table
-- ==============================
    SELECT 
	machine_id,
	process_id,
	activity_type,
	[timestamp]
FROM LC_1661_Activity)


, Aggregation AS
(
 -- ==================================
 -- Aggregation: Joining table by making two tabel and making it into big flat table
 -- =====================================   
    SELECT 
	a.machine_id,
	a.process_id,
	a.activity_type AS start_process ,
	a.timestamp AS start_time,
	b.activity_type AS end_process,
	b.timestamp AS end_time,
	b.timestamp - a.timestamp AS run_time
FROM base_report AS a
INNER JOIN base_report AS b
ON a.machine_id = b.machine_id
AND a.process_id = b.process_id
AND b.activity_type = 'end'
WHERE a.activity_type = 'start'
)


SELECT 
	machine_id,
	ROUND(AVG(run_time), 3) AS avg_run_time
FROM Aggregation
GROUP BY machine_id


/*
=====================
DDL commands
=====================


Create table LC_1661_Activity (machine_id int, process_id int, activity_type ENUM('start', 'end'), timestamp float)

Truncate table Activity

INSERT INTO LC_1661_Activity (machine_id, process_id, activity_type, timestamp)
VALUES
  ('0', '0', 'start', '0.712'),
  ('0', '0', 'end', '1.52'),
  ('0', '1', 'start', '3.14'),
  ('0', '1', 'end', '4.12'),
  ('1', '0', 'start', '0.55'),
  ('1', '0', 'end', '1.55'),
  ('1', '1', 'start', '0.43'),
  ('1', '1', 'end', '1.42'),
  ('2', '0', 'start', '4.1'),
  ('2', '0', 'end', '4.512'),
  ('2', '1', 'start', '2.5'),
  ('2', '1', 'end', '5')

  */