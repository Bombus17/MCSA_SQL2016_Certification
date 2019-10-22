USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: OUTPUT data

-- can output Inserted or Deleted rows when using DML scripts
-- 
---------------------------------------------------------------------------------------*/


/* OUTPUT.Deleted
------------------------------*/
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

/* OUTPUT.Inserted data

-- can Insert with Values
-- or insert Select
------------------------------*/

DECLARE @Inserted table (StaffID INT
						, FirstName NVARCHAR(50)
						, LastName NVARCHAR(50)
						, CountryRegion NVARCHAR(50)
						)

INSERT INTO dbo.SalesAssistant (StaffID, FirstName, LastName, CountryRegion)
OUTPUT	INSERTED.StaffID
		, INSERTED.FirstName
		, INSERTED.LastName
		, INSERTED.CountryRegion
INTO @Inserted
VALUES (100, 'William', 'Wallace', 'Scotland')
, (200, 'Teresa', 'May', 'England')

SELECT * FROM @Inserted;

/* OUTPUT.Inserted data

-- using insert Select
------------------------------*/

DECLARE @InsertedSelect table (StaffID INT
						, FirstName NVARCHAR(50)
						, LastName NVARCHAR(50)
						, CountryRegion NVARCHAR(50)
						)

INSERT INTO dbo.SalesAssistant (StaffID, FirstName, LastName, CountryRegion)
OUTPUT	INSERTED.StaffID
		, INSERTED.FirstName
		, INSERTED.LastName
		, INSERTED.CountryRegion
INTO @InsertedSelect
SELECT TOP 10 BusinessEntityID
			, FirstName
			, LastName
			, 'England'
FROM Person.Person

SELECT * FROM @InsertedSelect;
