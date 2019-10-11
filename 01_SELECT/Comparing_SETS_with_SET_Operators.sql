USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Combining Sets with Set Operators

-- UNION
-- UNION ALL
-- INTERSECT
-- EXCEPT

--N.B.
-- Always operate on 2 result sets of queries, comparing complete rows between the results
-- Number of colums must be the same
-- Column types must be compatible
-- use distinctness based comparison (rather than equality based)
-- hence, comparison of 2 NULLs = TRUE and comparison of NULL and Non NULL = False
-- individual queries are not allowed to have ORDER BY clauses
-- column names are determined by the first query

---------------------------------------------------------------------------------------*/

/* UNION

-- retrieve a list of sales and non-sales employees

-- implied DISTINCT property
-- does not return duplicate records
-- note column names dictated by first query
----------------------------------------------*/


SELECT FirstName, LastName, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
										WHEN 'SP' THEN 'Sales Person' END AS [Role]
FROM Person.Person
WHERE PersonType = 'EM' -- Employee (non-sales)

UNION 

SELECT FirstName, LastName, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
										WHEN 'SP' THEN 'Sales Person' END
FROM Person.Person
WHERE PersonType = 'SP'; -- SP = Sales Person

/* UNION ALL 
-- does not include duplicates
-------------------------------------------*/

SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END AS [Role]
FROM Person.Person
WHERE PersonType = 'EM' -- Employee (non-sales)

UNION ALL

SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END
FROM Person.Person
WHERE PersonType = 'SP'; -- SP = Sales Person

/* INTERSECT 
-- returns distinct rows that are common in both sets
-- TODO: find a better example
-------------------------------------------------------*/
SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END AS [Role]
FROM Person.Person
WHERE PersonType = 'EM' -- Employee (non-sales)

INTERSECT

SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END
FROM Person.Person
WHERE PersonType = 'SP'; -- SP = Sales Person

/* EXCEPT 
-- set difference
--rows in first query but not the second
-------------------------------------------------------*/
SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END AS [Role]
FROM Person.Person
WHERE PersonType = 'EM' -- Employee (non-sales)

EXCEPT

SELECT FirstName, LastName
	, CASE PersonType WHEN 'EM' THEN 'Employee (non-sales)'
						WHEN 'SP' THEN 'Sales Person' END
FROM Person.Person
WHERE PersonType = 'SP'; -- SP = Sales Person

