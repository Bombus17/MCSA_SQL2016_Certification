USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: DELETE data

-- delete data
-- truncate
-- delete vs truncate
-- output rows
-- transactions
-- batch deletions

TODO: finish this script
---------------------------------------------------------------------------------------*/

/* DELETE 
-------------------------------------*/
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


/* DELETE vs TRUNCATE 

-- TRUNCATE reseeds identity values, whereas DELETE doesn't. 
-- TRUNCATE removes all records and doesn't fire triggers. 
-- TRUNCATE is faster compared to DELETE as it makes less use of the transaction log.
-----------------------------*/

/* OUTPUT deleted data 
------------------------*/

DECLARE @Output table
(
  StaffID INT,
  FirstName NVARCHAR(50),
  LastName NVARCHAR(50),
  CountryRegion NVARCHAR(50)
);
DELETE ss
OUTPUT DELETED.* INTO @Output
FROM Sales.vSalesPerson sp
  INNER JOIN [dbo].[SalesAssistant] ss
  ON sp.BusinessEntityID = ss.StaffID
WHERE sp.SalesLastYear = 0;
SELECT * FROM @output;

RETURN;

/* DELETE by batch in a transaction

-- Delete in batches of 100,000 rows 
-- Each batch is in its own transaction
-- So if the batch stops, previous batches will have been committed
-- add CHECKPOINT or BACKUP LOG options to minimise transaction log impacts

---------------------------------------*/

SET NOCOUNT ON;
 
DECLARE @row INT;
 
SET @row = 1;
 
WHILE @row > 0
BEGIN
  BEGIN TRANSACTION;
 
  DELETE TOP (100000) 
   -- dbo.SalesOrderDetailHeader
    WHERE ProductID IN (712, 870, 873);
 
  SET @row = @@ROWCOUNT;
 
  COMMIT TRANSACTION;

END