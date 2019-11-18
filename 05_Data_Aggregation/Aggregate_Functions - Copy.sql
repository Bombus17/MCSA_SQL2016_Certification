USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Aggregate functions

-- standard aggregate functions: MIN, MAX, AVG, SUM, COUNT 
-- MEDIAN N.B. There is no Median function, use PERCENTILE_CONT, a subquery or a partitioned set
-- NULLs 
-- operators and aggregations
-- Query tuning (SARGability)

--N.B.
--Aggregate functions ignore NULL when applied to an expression
--COUNT(*) counts rows and returns an INT value
--Use COUNT_BIG to return BIGINT

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

/* Nth highest in a table 
---------------------------------*/
/* second highest salary */
SELECT MAX(Salary) 
FROM dbo.Employees
WHERE salary NOT IN (select max(salary) from dbo.Employees);

/*  USE A CTE 
	3rd highest salary. Why DENSE_RANK() no gaps in the ranking values 
	--------------------------------------------------------------------
*/
WITH salaries AS
	( SELECT *,
	DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rnk
	FROM employees
	)
SELECT *
FROM Salaries
WHERE RNK = 3;

/* use correlated sub query 
	for each record processed by the outer query the inner query returns 
	how many records has a value less than the value stated (2 in this example)
----------------------------------------------------------------------------*/
SELECT Salary
FROM Employees e
WHERE 2=(SELECT COUNT(DISTINCT Salary) 
         FROM Employees p
         WHERE e.Salary<=p.Salary) 


/* Return multiple aggregations

--------------------------------------------------*/
SELECT AccountNumber
	, ROUND(SUM(TotalDue),2) AS TotalSales
	, ROUND(MIN(TotalDue),2) AS MIN_Sale
	, ROUND(MAX(TotalDue),2) AS MAX_Sale
	, ROUND(AVG(TotalDue),2) AS Avg_Sale
FROM Sales.SalesOrderHeader
WHERE PurchaseOrderNumber IS NOT NULL
GROUP BY AccountNumber
ORDER BY AccountNumber DESC;

/* return MEDIAN VALUE 
------------------------------*/
SELECT SalesOrderID, OrderQty, ProductID,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ProductID)
OVER (PARTITION BY SalesOrderID) AS MedianCont
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY SalesOrderID DESC;

/* Total customers with large orders (> 5,000)
-----------------------------------------------*/

SELECT COUNT(CustomerID) TotalCustomers
FROM Sales.SalesOrderHeader 
WHERE TotalDue > 5000;

/* STD Deviation
-- Standard Deviation of all List Prices in the products table
----------------------------------------------*/

SELECT  ROUND(STDEV(ListPrice),2) AS STD_DEV_ListPrice
FROM Production.Product;

/* NULL
-- aggregate functions ignore NULL inputs when applied to an expression
-- COUNT(*) counts rows and returns the result as an INT value but doesn't count NULL
--------------------------------------------------------------*/

/* OPERATORS and Aggregate functions
-- For example to calculate the MEDIAN of a value 
-------------------------------------------------------*/

DECLARE @Count AS INT = (SELECT COUNT(*) from Sales.SalesOrderDetail)

SELECT AVG(1.0 * OrderQty) AS Median
FROM (SELECT OrderQty
	FROM Sales.SalesOrderDetail
	Order by OrderQty
	OFFSET (@Count - 1) / 2 ROWS FETCH NEXT 2 - @Count % 2 ROWS ONLY) as D;

-- This returns a Median order quantity of 1.0 

/* SEARCH ARGUMENT considerations are imperative when considering query performance

-- A filter is SARGABLE if:
1. Do not apply manipulation to the filtered column
2. The operator identifies a consecutive range of qualifying rows in the index
	For example, operators such as =, >, >=, <, <=, BETWEEN, LIKE with a known prefix etc.
	This is not the case with operators such as <>, LIKE with a wildcard (%) prefix

	-------------------------------------------------------------------*/

	/* Difference between MIN and MAX qty */

	SELECT SpecialOfferID, [Description], MaxQty - MinQty AS [Diff]
	FROM Sales.SpecialOffer;

