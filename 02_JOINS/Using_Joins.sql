USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: JOINS

-- Correct use of Joins
-- INNER JOIN
-- LEFT/RIGHT/FULL OUTER JOIN
-- CROSS JOIN
-- JOIN operators (AND OR)
-- Using NULLs in joins

TODO: finish this script
---------------------------------------------------------------------------------------*/
/* CROSS JOINS

-- returns all possible combinations of every row from two tables
-- one logical query processing phase- a Cartesian product
-- two tables as input to return a table representing a Cartesian product
-- no matching is performed on columns, therefore no join conditions
-- performance considerations are important when querying large tables 
-- can behave like an inner join when a WHERE clause is used
-- can be used in a self join 
-------------------------------------------------------------------------*/

SELECT TOP 500 CustomerID, BusinessEntityID
FROM SALES.Customer 
CROSS JOIN HumanResources.Employee ;
