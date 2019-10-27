USE AdventureWorks2017
GO

/* Common Table Expressions */

WITH sd AS ( SELECT SalesOrderID	
			, ProductID
			FROM Sales.SalesOrderDetail
			)
SELECT sh.SalesOrderID
	, sh.OrderDate
	, ProductID
FROM Sales.SalesOrderHeader sh
INNER JOIN sd
	ON sh.SalesOrderID = sd.SalesOrderID;


