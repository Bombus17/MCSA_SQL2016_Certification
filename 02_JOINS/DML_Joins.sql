USE AdventureWorks2017
GO


/* DELETE 
-- delete rows using joins
-- SQL server extension

-- run SalesAssistant_Table_TestData.sql
-------------------------------------------*/


SELECT *
FROM dbo.SalesAssistant;

/* delete where there are no sales from last year 
-- first specify the table targeted for deletion
-- the join creates a table with the lookup information
---------------------------------------------------------*/
DELETE ss
FROM Sales.vSalesPerson sp
  INNER JOIN dbo.SalesAssistant ss
  ON sp.BusinessEntityID = ss.StaffID
WHERE sp.SalesLastYear = 0;

/* Could also use a CTE

-----------------------------------------------*/

WITH cteSalesPerson
  AS
  (
    SELECT BusinessEntityID
    FROM Sales.vSalesPerson
    WHERE SalesLastYear = 0 
  )
DELETE ss
FROM cteSalesPerson sp
  INNER JOIN dbo.SalesAssistant ss
  ON sp.BusinessEntityID = ss.StaffID;

/* Could also reference the CTE in a subquery 
------------------------------------------------*/

WITH cteSalesPerson
  AS
  (
    SELECT BusinessEntityID
    FROM Sales.vSalesPerson
    WHERE SalesLastYear = 0 
  )
DELETE dbo.SalesAssistant
WHERE StaffID IN 
  (SELECT* FROM cteSalesPerson);