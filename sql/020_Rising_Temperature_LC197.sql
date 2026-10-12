WITH Aggregation AS
(SELECT 
/*===============================================
Aggregation: Check if the datedifference is 1 day then compare curent and previous temperature
================================================*/
	id,
	recordDate,
	temperature AS currentTemp,
	CASE 
		WHEN DATEDIFF(DAY,  LAG(recordDate) OVER (ORDER BY recordDate ASC), recordDate) = 1 AND 
				temperature > LAG(temperature) OVER (ORDER BY recordDate) THEN 1
		ELSE 0
	END AS flag
	-- DATEDIFF(DAY, recordDate, LAG(recordDate) OVER (ORDER BY recordDate ASC))
FROM LC_197_Weather
)


SELECT 
	id
	--recordDate,
	--flag
FROM Aggregation
WHERE flag = 1