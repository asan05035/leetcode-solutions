/*
========================================
Question: Find how many users who speak more than 2 language in each companies
=========================================
*/


WITH base_query AS
(
/*
================================================
Base query: Retreive all columns needed from the table
================================================
*/

SELECT 
	company_id, 
	user_id, 
	language
FROM complex.company_users
)


,Aggregation AS (
/*
================================================
Aggregation:
			-- Counting no. of language users known
			-- Flagging users who know more than 2 languages
================================================
*/

SELECT 
	company_id, 
	user_id, 
	COUNT(language) languages_known,
	CASE 
		WHEN COUNT(language) >= 2 THEN 1
		ELSE 0
	END AS flag
FROM base_query
GROUP BY company_id, user_id)


/*
==============================================
Final query: 
			-- Counting users who know morethan 2 kanguage by binary flag
==============================================
*/

SELECT 
	company_id, 
	SUM(flag) AS users
FROM Aggregation
GROUP BY company_id




/*
=========================
DDL Script:
			-- For creating and ingesting data 
Source: 
		-- Ankit bansal (youtube)
==========================
*/
USE master;
GO 

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ProblemSolving')
BEGIN
	DROP DATABASE ProblemSolving
END

CREATE DATABASE ProblemSolving;
GO

CREATE SCHEMA complex;
GO 

IF OBJECT_ID('complex.company_users', 'u') IS NOT NULL
	DROP TABLE complex.company_users

create table complex.company_users 
(
company_id int,
user_id int,
language varchar(20)
);

TRUNCATE TABLE complex.company_users
insert into complex.company_users values (1,1,'English')
,(1,1,'German')
,(1,2,'English')
,(1,3,'German')
,(1,3,'English')
,(1,4,'English')
,(2,5,'English')
,(2,5,'German')
,(2,5,'Spanish')
,(2,6,'German')
,(2,6,'Spanish')
,(2,7,'English'),
(2, 6, 'English')
,(2, 7, 'Hindi')
, (3, 1, 'Hindi')
, (3, 1, 'Telgu');


