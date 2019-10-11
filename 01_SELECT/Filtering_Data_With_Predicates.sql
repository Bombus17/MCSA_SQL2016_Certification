USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: 
Using the WHERE Clause
Filtering Data with Predicates 

N.B.:
Most queries require some sort of filtering. 
Always consider three valued logic when designing filters: True, False, NULL

---------------------------------------------------------------------------------------*/
/* Return a list of Products 

*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product];

/* Filter for only red products 
--N prefix on colour column denotes a unicode character string literal (Colour column is NVARCHAR(15))

*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE Color = N'Red';

  /* Select products which are not Red 
  -- 3 valued logic 
  -- Red = False
  -- Not Red (black, silver etc.) = True
  -- NULL returns NULL (hence Colour IS NULL)
  -----------------------------------------------*/

SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE Color != N'Red' OR Color IS NULL;

/* Retrieve a list of all expensive products (price > 1000)
-- operators
--------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE ListPrice >= 1000;

  /* Retrieve a list of all large, heavy and expensive products (price > 1000)
-- use of operators
-- combining predicates
---------------------------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE ListPrice >= 1000 AND Size > 50 AND [Weight] > 20;

/* Retrieve a list of all heavy or expensive products (price > 1000)
-- use of operators
-- combining predicates
-- filter out products which have no price
---------------------------------------------------------------------------------*/
SELECT [Name] AS ProductName
      ,[ProductNumber]
      ,[Color]
      ,[ListPrice]
      ,[Size]
      ,[Weight]      
  FROM [Production].[Product]
  WHERE ([Weight] > 20 OR ListPrice >= 1000) AND ListPrice != 0.00;

/* coding challenge 
Try extending these queries using the NOT logical operator
NOT True = False
NOT False = True
Also consider NULLs
-------------------------------------------------------*/




