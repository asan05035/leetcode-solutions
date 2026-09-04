/*
=====================================================
Question:
	Find companies with atleast two users who speak english and german language
====================================================
*/


-- Company and english users
WITH english_users AS
(SELECT 
	company_id, 
	user_id, 
	language
FROM complex.company_users
WHERE language = 'English')


-- Company and german users
, german_users AS 
(SELECT 
	company_id, 
	user_id, 
	language
FROM complex.company_users
WHERE language = 'German')


-- Company and both language users
, multiple_language_users AS
(SELECT 
	e.company_id,
	e.user_id,
	'both' AS language
FROM english_users AS e
INNER JOIN german_users AS g
ON e.company_id = g.company_id 
AND e.user_id = g.user_id)



SELECT 
	company_id,
	COUNT(user_id) AS users_count
FROM multiple_language_users
GROUP BY company_id	
HAVING COUNT(user_id) >= 2




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
,(2,7,'English')
,(2, 7, 'German'),
(2, 6, 'English')
,(2, 7, 'Hindi')
, (3, 1, 'Hindi')
, (3, 1, 'Telgu');


