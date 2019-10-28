USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: T-SQL Selecting data

-- TOP (Number, PERCENT, using a variable, WITH TIES)
-- OFFSET and FETCH
-- SORTING Data (ORDER BY)

--N.B.
-- TOP and OFFSET FETCH are processed after the FROM, WHERE, GROUP BY and HAVING clauses
-- they are essentially an extension of the ORDER BY clause
-- OFFSET-FETCH is standard whereas TOP is not
-- Due to its skipping capability it has an advantage over TOP
-- BUT: OFFSET-FETCH does not offer the PERCENT or WITH TIES options of TOP
-- for optimised performance, consider indexing the ORDER BY columns
---------------------------------------------------------------------------------------*/


/* Retrieve the 5 most recent orders using TOP

-- value in parentheses is a BIGINT typed value
-- sort descending to get the most recent first
-- without the DESC keyword, the ORDER BY sorts ASC by default
-- ORDER BY clause isn't mandatory
-- however the query isn't deterministic
-- recommend to include an ORDER BY clause 
------------------------------------------------------------*/
SELECT TOP(5) SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC;

---------------------------------------------------------------------------------------*/
/* Retrieve data using WITH TIES

-- Suppose there are other rows with the same order date as in the last row
-- use WITH TIES to include these rows
-- returns > 5 rows but all have the same order date
------------------------------------------------------------*/
SELECT TOP(5) WITH TIES SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC;

---------------------------------------------------------------------------------------*/
/* Retrieve the TOP 5 % ORDERS

-- value in parentheses is a FLOAT value
-- option computes the ceiling value (e.g. 7.6 equates to 8)
------------------------------------------------------------*/
SELECT TOP(5) PERCENT SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC;

---------------------------------------------------------------------------------------*/
/* Retrieve the TOP x  ORDERS using a variable

-- pass value as a variable
------------------------------------------------------------*/
DECLARE @Num AS BIGINT = 12;

SELECT TOP(@Num) SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC;

---------------------------------------------------------------------------------------*/
/* Retrieve data using OFFSET FETCH

-- can be used to skip rows
-- OFFSET -- how many rows to skip (0 if none)
-- FETCH -- number of rows to filter

--N.B.
-- must have an ORDER BY clause
-- FETCH clause requires an OFFSET clause
-- OFFSET does not require a FETCH clause 
-- NEXT and FIRST can be used interchangeably
------------------------------------------------------------*/


/* Get a batch of 35 sales details but skip the first 50 rows 
---------------------------------------------------------------*/
SELECT SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC, SalesOrderID DESC
OFFSET 50 ROWS FETCH NEXT 35 ROWS ONLY;

/* Get a batch of 25 sales details 

-- essentially the same as selecting the top (25) rows
-- but has an advantage due to its skipping capability
---------------------------------------------------------------*/
SELECT SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC, SalesOrderID DESC
OFFSET 0 ROWS FETCH NEXT 25 ROWS ONLY;

SELECT TOP (25) SalesOrderID, OrderDate, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC, SalesOrderID DESC
