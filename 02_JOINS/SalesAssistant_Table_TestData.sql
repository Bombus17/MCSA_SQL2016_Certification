USE AdventureWorks2017
GO

/* test data table for DML join script */


IF OBJECT_ID ('dbo.SalesAssistant', 'U') IS NOT NULL DROP TABLE dbo.SalesAssistant;
 
CREATE TABLE dbo.SalesAssistant
(
  StaffID INT NOT NULL PRIMARY KEY,
  FirstName NVARCHAR(50) NOT NULL,
  LastName NVARCHAR(50) NOT NULL,
  CountryRegion NVARCHAR(50) NOT NULL
);
 
INSERT INTO dbo.SalesAssistant
SELECT BusinessEntityID, FirstName, 
  LastName, CountryRegionName
FROM Sales.vSalesPerson;

