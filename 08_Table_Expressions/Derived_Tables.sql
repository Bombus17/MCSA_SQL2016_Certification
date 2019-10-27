USE AdventureWorks2017
GO

/* Derived Tables */

SELECT sh.SalesOrderID
	, sh.OrderDate
	, ProductID
FROM Sales.SalesOrderHeader sh
INNER JOIN (SELECT SalesOrderID, ProductID
			FROM Sales.SalesOrderDetail) AS sd
		ON sh.SalesOrderID = sd.SalesOrderID;

