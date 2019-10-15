USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: JOINS

-- Correct use of Joins
-- CROSS JOIN
-- CROSS APPLY
-- Difference between CROSS JOIN and CROSS APPLY (see the APPLY script for more detailed examples)
-- INNER JOIN
-- OUTER JOIN (LEFT/RIGHT/FULL) **
-- OUTER APPLY
-- Difference between OUTER JOIN and OUTER APPLY
-- Composite Joins
-- Multiple Joins
-- JOIN operators (AND OR)
-- Using NULLs in joins

TODO: Finalise this script
---------------------------------------------------------------------------------------*/
/* CROSS JOIN

-- returns all possible combinations of every row from two tables
-- one logical query processing phase- a Cartesian product
-- two tables as input to return a table representing a Cartesian product
-- no matching is performed on columns, therefore no join conditions
-- performance considerations are important when querying large tables 
-- can behave like an inner join when a WHERE clause is used
-- can be used in a self join 
-- there is no ON clause as it is inferred from the syntax 
-- WHERE clause filters (predicate pushdown)
-------------------------------------------------------------------------*/

/* returns every combination of business entity and customer 
------------------------------------------------------------*/
SELECT TOP 500 CustomerID, BusinessEntityID
FROM SALES.Customer 
CROSS JOIN HumanResources.Employee ;

/* DIFFERENCE BETWEEN CROSS JOIN and CROSS APPLY 

-- JOIN treats inputs as sets of inputs (no correlation, no order)
-- APPLY operator applies query logic to each row
-- allows for correlation for multiple columns and rows

-- CROSS APPLY 
-- right table expression applied to each row from left input
-- if right table expression returns an empty set for the left row
-- the left row isn't returned (see also OUTER APPLY)
----------------------------------------------------------*/

/* INNER JOIN
-- match rows based on predicate (ON) clause
-- ON and WHERE clauses filter rows where predicate evaluates to True
-- INNER JOIN is the default join when using the syntax JOIN
--
--------------------------------------------------------*/

/* Find all employees, their job title and age they were employed 
-- all employees that reside in the person table
-----------------------------------------------------------------*/

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName, emp.JobTitle, emp.Gender, emp.HireDate
	, DATEDIFF(YY, emp.BirthDate, emp.HireDate) AS AgeEmployed
FROM Person.Person p
INNER JOIN [HumanResources].[Employee] emp
ON p.BusinessEntityID = emp.BusinessEntityID;

/* OUTER JOIN 

-- all rows from 1 or both sides
-- LEFT, RIGHT or FULL
---------------------------------------------------------------------------*/

/* LEFT OUTER JOIN 

-- preserves LEFT table
-- returns rows unmatched rows from left table with NULL as placeholders in the right side
-- ON and WHERE clause have different roles (unlike INNER JOIN)
-- WHERE has filtering role, keeps true cases and discards false and unknown cases
-- ON predicate determines which rows from the nonpreserved side are matched to those of the preserved side
-- So WHERE filters and ON matches. Remember the logical query processing order
-- here ON is not final (wrt the preserved side) whereas WHERE is. 

-- RIGHT OUTER JOIN is essentially the same but the right table is preserved
-- FULL OUTER JOIN both sides are preserved with NULL as placeholders for unmatched rows from either side
-----------------------------------------------------------------------------------------------------*/

SELECT st.[Group] AS Region, st.[Name] AS TerritoryName, COUNT(soh.CustomerID) AS Total_Customers
FROM [Sales].[SalesOrderHeader] soh
LEFT OUTER JOIN [Sales].[SalesTerritory] st
ON st.TerritoryID = soh.TerritoryID
GROUP BY st.[Group], st.[Name]
ORDER BY Region;




