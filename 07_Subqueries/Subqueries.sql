USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: SUB QUERIES

-- self contained 
-- correlated **
-- ANY and SOME predicates
-- EXISTS
-- NOT EXISTS
-- optimisation
-- nested sub queries

TODO: finish this script
--------------------------------------------------------------------------
-------------*/

/* All products that have been ordered
--------------------------------------*/

SELECT ProductID, [Name] AS ProductName, Color, ListPrice
FROM Production.Product
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail);

/* Products that have yet to be ordered
---------------------------------------*/
SELECT ProductID, [Name] AS ProductName
, Color
, ListPrice
FROM Production.Product
WHERE ProductID NOT IN (SELECT ProductID 
						FROM Sales.SalesOrderDetail
						WHERE ProductID IS NOT NULL);