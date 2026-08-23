
-- select * from icc_world_cup;

with cte_team_plays as(
SELECT teams as team_name,
		COUNT(teams) AS no_matches_played
FROM(
	SELECT Team_1 AS teams
	FROM [dbo].[icc_world_cup]

	UNION ALL

	SELECT Team_2
	FROM [dbo].[icc_world_cup]) t
GROUP BY t.teams
)

, cte_team_wins as (
select 
	Winner AS team_name,
	COUNT(Winner) AS no_of_wins
from [dbo].[icc_world_cup]
GROUP BY Winner
)

SELECT 
	ctp.team_name,
	ctp.no_matches_played,
	COALESCE(ctw.no_of_wins, 0) AS no_of_wins,
	ctp.no_matches_played - COALESCE(ctw.no_of_wins, 0) AS no_of_losses,
	ctp.no_matches_played * COALESCE(ctw.no_of_wins, 0) AS points_table 
FROM cte_team_plays AS ctp
LEFT JOIN cte_team_wins AS ctw
ON ctp.team_name = ctw.team_name


SELECT 
	t.Team_1 AS team_name,
	COUNT(*) AS no_of_matches_played,
	SUM(WinFlag) AS no_of_wins,
	COUNT(*) - SUM(WinFlag) AS points_table
FROM (SELECT Team_1,
	CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END AS WinFlag
FROM dbo.icc_world_cup

UNION ALL

SELECT Team_2,
	CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END AS WinFlag
FROM dbo.icc_world_cup) t
GROUP BY t.Team_1 