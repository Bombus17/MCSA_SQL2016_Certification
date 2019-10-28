USE AdventureWorks2017
GO

---------------------------------------------------------------------
-- UNION and UNION ALL
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
---------------------------------------------------------------------

-- locations that are both employee and customer locations
SELECT country, region, city
FROM HR.Employees

INTERSECT

SELECT country, region, city
FROM Sales.Customers;

---------------------------------------------------------------------
-- EXCEPT
---------------------------------------------------------------------

-- locations that are employee locations but not customer locations
SELECT country, region, city
FROM HR.Employees

EXCEPT

SELECT country, region, city
FROM Sales.Customers;

-- cleanup
DROP TABLE IF EXISTS Sales.Orders2;
