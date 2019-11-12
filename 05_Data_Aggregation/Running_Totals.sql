USE AdventureWorks2017
GO

with monthsales AS (
					SELECT DATEPART(MONTH, OrderDate) AS MNTH, TotalDue
					FROM Sales.SalesOrderHeader
					)


/* use CROSS APPLY 
-----------------*/

--SELECT m1.Mnth, m1.TotalDue, TotalSales = YTD
--FROM monthsales m1
--CROSS APPLY (SELECT SUM(TotalDue) FROM monthsales M 
--			WHERE M.MNTH <= m1.MNTH) M(YTD);

/* USE WINDOW FUNCTION 
-------------------------*/

SELECT mnth, TotalDue, SUM(TotalDue) OVER (ORDER BY Mnth ASC ROWS UNBOUNDED PRECEDING) AS TotalSales
FROM monthsales;

/* use a Sub query */
--SELECT m1.Mnth, m1.TotalDue, Total_Sales = (SELECT SUM(TotalDue) from monthsales m
--											WHERE m.Mnth <= m1.Mnth)
--FROM monthsales m1;


