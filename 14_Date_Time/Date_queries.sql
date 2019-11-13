USE AdventureWorks2017
GO

/* Find first Wednesday of each month in a given year */

WITH dts AS (
		SELECT dt = DATEADD(day, n-1, '20190101') 
		FROM (SELECT TOP (366) n=ROW_NUMBER() OVER (ORDER BY (SELECT 1))
			master..spt_values
			CROSS JOIN master..spt_values v2) T(n)
		WHERE DATEPART(WEEKDAY, DATEADD(DAY, n-1, '20190101')+@@DATEFIRST-1) = 3
		AND DATEADD(DAY,n-1,'20190101') < '20191231'
		)
SELECT MIN(dt)
FROM dts
GROUP BY (DATEPART(MONTH,dt));

/* FIRST DAY OF THE MONTH*/
SELECT DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) AS StartOfMonth
	,DATENAME(DW,(DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) AS [DayOfWeek];


