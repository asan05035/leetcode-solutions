/* SELECT *
FROM dbo.persons; */


/*-----------------------------------------------------
 Write a query to find the personID, name, number of friends, sum of marks
 of person who have friends with total score of greater than 100
 -----------------------------------------------------*/


WITH CTE_no_of_friends AS (
SELECT 
	PersonID,
	COUNT(FriendID) AS no_of_friends
FROM dbo.friend 
GROUP BY PersonID)
,

CTE_friends_score AS (
SELECT 
	f.PersonID,
	-- f.FriendID,
	SUM(p.Score) friends_score
FROM dbo.friend AS f
LEFT JOIN dbo.persons AS p
ON f.FriendID = p.PersonID
GROUP BY f.PersonID)

SELECT p.*,
		cnof.no_of_friends,
		cfs.friends_score
FROM dbo.persons AS p
LEFT JOIN CTE_no_of_friends AS cnof
ON p.PersonID = cnof.PersonID
LEFT JOIN CTE_friends_score AS cfs
ON p.PersonID = cfs.PersonID
WHERE cfs.friends_score > 100
 

SELECT *
FROM dbo.friend



SELECT t.person_id,
	COUNT(*) friend_count
FROM (
-----
SELECT 
	PersonID AS person_id,
	FriendID AS friend_id
FROM dbo.friend

UNION

SELECT 
FriendID AS friend_id,
	PersonID AS person_id
FROM dbo.friend) t
GROUP BY person_id


SELECT 
	t.person_id,
	SUM(p.Score) AS total_score
FROM (SELECT 
	PersonID AS person_id,
	FriendID AS friend_id
FROM dbo.friend

UNION

SELECT 
FriendID AS friend_id,
	PersonID AS person_id
FROM dbo.friend) t
LEFT JOIN dbo.persons AS p
ON t.friend_id = p.PersonID
GROUP BY t.person_id