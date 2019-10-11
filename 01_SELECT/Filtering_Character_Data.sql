USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Filtering character data

-- correct form of literals
-- LIKE predicate
-- Wildcards and LIKE patterns
-- ESCAPE keyword

N.B.:
Most queries require some sort of filtering. 
Always consider three valued logic when designing filters: True, False, NULL

---------------------------------------------------------------------------------------*/

/* Let's analyse the products data 
-- the Name column (note column alias) is Unicode character string
-- to efficiently rely on indexing and employ best practice use the correct literal form
-------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] = N'Blade'

  /* LIKE predicates follow the same rules 
  -- here we return a list of products where the name begins with HEX
  -- note wildcard search
  ----------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'Hex%'

 /* Retrieve all products beginning with C
  ----------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'D%'

/* Retrieve all products where the second character is A
  ----------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'_a%'

  /* Retrieve all products where the first character is a or b
  --------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'[AB]%'

  /* Retrieve all products where the first character is a number
  --------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'[0-9]%'


/* use ESCAPE keyword to look for characters that are considered a wildcard
-- find _ (underscore) 
-- N.B. could also use square brackets []
  --------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE [Name] LIKE  N'!_%' ESCAPE'!'