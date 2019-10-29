USE AdventureWorks2017
GO

-- PRECEDENCE (L T R)
-- INTERSECT > UNION > EXCEPT


---------------------------------------------------------------------
-- UNION and UNION ALL

-- distinctness based set comparison

-- UNION 
-- DISTINCT properties
-- careful with ORDER BY clause
-- column names in first set are the output column names of the query

-- UNION ALL 
-- All rows obviously
-- more performant in terms of Index cost to use this when certain there is no potential for duplicates
---------------------------------------------------------------------

-- locations that are employee locations or customer locations or both
SELECT country, region, city
FROM HR.Employees

UNION

SELECT country, region, city
FROM Sales.Customers;

-- with UNION ALL duplicates are not discarded
SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Sales.Customers;

---------------------------------------------------------------------
-- INTERSECT

-- rows common to both sets
-- distinct rows
---------------------------------------------------------------------

-- locations that are both employee and customer locations
SELECT country, region, city
FROM HR.Employees

INTERSECT

SELECT country, region, city
FROM Sales.Customers;

---------------------------------------------------------------------
-- EXCEPT

-- SET difference
-- distinct rows
-- first query but not the second
---------------------------------------------------------------------

-- locations that are employee locations but not customer locations
SELECT country, region, city
FROM HR.Employees

EXCEPT

SELECT country, region, city
FROM Sales.Customers;

-- cleanup
DROP TABLE IF EXISTS Sales.Orders2;
