USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Aggregate functions

-- standard aggregate functions: MIN, MAX, AVG, SUM, COUNT
-- NULLs
-- operators and aggregations
-- Query tuning (SARGability)

--N.B.
--Aggregate functions ignore NULL when applied to an expression
--COUNT(*) counts rows and returns an INT value
--Use COUNT_BIG to return BIGINT

TODO: finish this script
---------------------------------------------------------------------------------------*/
/* Retrieve the highest sale amount per customer

*/
SELECT TOP 10 HighestSale, COUNT(CustomerID) AS TotalCustomers
FROM ( 
	SELECT soh.CustomerID, MAX(TotalDue) AS HighestSale
	FROM [Sales].[SalesOrderHeader] soh
	GROUP BY soh.CustomerID
	) S
GROUP BY HighestSale
HAVING COUNT(CustomerID)  > 5
ORDER BY TotalCustomers DESC