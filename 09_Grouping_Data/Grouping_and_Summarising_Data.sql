USE AdventureWorks2017
GO

/* Grouping and Summarising Data 
 -- using aggregate functions
 -- using GROUP by clause
 -- GROUPING SETS

---------------------------------------------*/

/* aggregate functions */

SELECT COUNT(1) AS TotalCustomers
FROM Sales.Customer;


SELECT SUM(OrderQty) AS TotalProductsOrdered
FROM Sales.SalesOrderDetail;

SELECT MAX(UnitPrice) AS ExpensiveProduct
FROM Sales.SalesOrderDetail;

SELECT AVG(Freight) AS AverageFreight
FROM Sales.SalesOrderHeader;

SELECT MIN(ListPrice) AS MinListPrice
	, MAX(ListPrice) AS MaxListPrice
	, AVG(ListPrice) AS AVGListPrice
FROM Production.Product;

/* GROUP BY clause */

SELECT SUM(OrderQty) AS TotalOrdered, ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID;


