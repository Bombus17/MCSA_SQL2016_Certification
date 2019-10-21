USE AdventureWorks2017
GO


/*---------------------------------
--Hints are options and strategies specified for enforcement by the query optimiser
-- on SELECT, INSERT, UPDATE or DELETE statements
-- The hints override the execution plan the query optimiser might select for a query

-- JOIN HINTS
-- specify that the query optimiser specify a join strategy between tables

-- LOOP | HASH | MERGE | REMOTE

-- Notes:
-- LOOP cannot be used with RIGHT or FULL join types
-- REMOTE can only be used for INNER join operations
-- REMOTE cannot be used if one of the predicates is CAST to a different COLLATION
-----------------------------------------------------------------------------------*/

/* HASH join

---------------------------------------------*/

SELECT p.[Name] AS ProductName, pr.ProductID
FROM Production.Product p
LEFT OUTER HASH JOIN Production.ProductReview pr
ON p.ProductID = pr.ProductID
ORDER BY pr.ProductReviewID DESC; 

/*  LOOP  join
-- used with a DELETE statement to loop through
-------------------------*/

SELECT sp.*
FROM Sales.SalesPersonQuotaHistory sp
INNER LOOP JOIN Sales.SalesPerson s
ON sp.BusinessEntityID = s.BusinessEntityID
WHERE s.SalesYTD > 300000;

/*  MERGE  join
-- used with a DELETE statement to loop through
-------------------------*/

SELECT ph.PurchaseOrderID, ph.OrderDate, pd.ProductID, pd.DueDate, ph.VendorID
FROM Purchasing.PurchaseOrderHeader ph
INNER MERGE JOIN Purchasing.PurchaseOrderDetail pd
ON ph.PurchaseOrderID = pd.PurchaseOrderID;








