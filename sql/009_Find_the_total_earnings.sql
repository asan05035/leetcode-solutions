/*

SELECT *
FROM sql_SCD_TYPE2_billings;

SELECT *\FROM sql_SCD_TYPE2_HoursWorked;

*/



WITH Aggregation AS
(
/*----------------------
Aggregation: Find the last date for rate slab -- > within date
--------------------*/

SELECT 
	b.emp_name,
	b.bill_date AS StartDate,
	LEAD(b.bill_date, 1, GETDATE()) OVER (PARTITION BY b.emp_name ORDER BY b.bill_date ASC) EndDate,
	b.bill_rate
FROM sql_SCD_TYPE2_billings AS b
)

, Joining AS (
/*--------------------------
Joinging: combining two table based on dates within
----------------------------*/
SELECT 
	a.emp_name,
	StartDate,
	EndDate,
	bill_rate,
	h.work_date,
	h.bill_hrs AS work_hour,
	bill_rate * h.bill_hrs AS work_charge
FROM Aggregation AS a
LEFT JOIN dbo.sql_SCD_TYPE2_HoursWorked AS h
ON a.emp_name = h.emp_name AND (a.StartDate < h.work_date AND h.work_date <= a.EndDate)

)

SELECT 
	emp_name,
	SUM(COALESCE(work_charge,0)) AS total_earnings
FROM Joining
GROUP BY emp_name

/*=======================================================
Topics used: 
		-- Lead(3 arguemnts) + default 
		-- How to join two rows in a table using date column and handle null 





/* Init Database

create table sql_SCD_TYPE2_billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);

insert into sql_SCD_TYPE2_billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;

create table sql_SCD_TYPE2_HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into sql_SCD_TYPE2_HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)

*/