/*---------------------
1.Identify users using multiple devices
----------------------*/
WITH spending_details AS 
(SELECT 
	s.spend_date,
	s.user_id,
	CASE 
		WHEN COUNT(DISTINCT s.platform) > 1 THEN 'both'
		ELSE MAX(s.platform)
	END AS platform, 
	SUM(s.amount) AS total_spends
FROM dbo.sql_11_spending AS s
GROUP BY s.spend_date, s.user_id
)
, DateAndPlatforms AS (
SELECT DISTINCT spend_date, 'mobile' AS platform
FROM dbo.sql_11_spending

UNION ALL

SELECT DISTINCT spend_date, 'desktop' AS platform
FROM dbo.sql_11_spending

UNION ALL


SELECT DISTINCT spend_date, 'both' AS platform
FROM dbo.sql_11_spending
)

SELECT 
	dp.spend_date,
	dp.platform,
	SUM(sd.total_spends) total_spend_each_platform,
	COUNT(sd.user_id)
FROM DateAndPlatforms AS dp
LEFT JOIN spending_details as sd
ON dp.spend_date = sd.spend_date AND dp.platform = sd.platform
GROUP BY 	dp.spend_date,
	dp.platform
	ORDER BY dp.spend_date


