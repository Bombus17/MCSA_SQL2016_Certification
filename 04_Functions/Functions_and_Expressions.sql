USE AdventureWorks2017
GO

/* Using Functions and Expresssions 
-- format data
-- assign alternative references
-----------------------------------*/


SELECT AddressLine1 + ' (' + City + ' ' + PostalCode + ')' AS [Address Format]
FROM Person.Address;

SELECT ProductID
	, ISNULL(Color, 'No Colour') AS Colour
	, [Name] AS ProductName
FROM Production.Product;

SELECT ProductID, [Name] + ISNULL(': ' + Color, '') AS [Product_Colour]
FROM Production.Product;

SELECT CAST(ProductID AS VARCHAR(5)) + ':' + [Name] AS [ID:Name]
FROM Production.Product;






