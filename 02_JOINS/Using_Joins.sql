USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: JOINS

-- Correct use of Joins
-- CROSS JOIN
-- CROSS APPLY
-- Difference between CROSS JOIN and CROSS APPLY (see the APPLY script for more detailed examples)
-- INNER JOIN
-- OUTER JOIN (LEFT/RIGHT/FULL) 
-- OUTER APPLY 
-- Difference between OUTER JOIN and OUTER APPLY 
-- see APPLY script for more examples of CROSS APPLY and OUTER APPLY

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
-- preferably the join is based on referential integrity
--------------------------------------------------------*/

/* Find all employees, their job title and age they were employed 
-- all employees that reside in the person table
-----------------------------------------------------------------*/

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName, emp.JobTitle, emp.Gender, emp.HireDate
	, DATEDIFF(YY, emp.BirthDate, emp.HireDate) AS AgeEmployed
FROM Person.Person p
INNER JOIN [HumanResources].[Employee] emp
ON p.BusinessEntityID = emp.BusinessEntityID;

/* ----------------------------------------------------
Retrieve all products where the price is > 1000

---------------------------------------------------*/
SELECT  TOP 100 P.ProductID, 
 P.[Name] AS ProductName, 
 P.ListPrice, 
 P.Size, 
 P.ModifiedDate, 
 sd.UnitPrice, 
 sd.UnitPriceDiscount,
 sd.OrderQty,
 sd.LineTotal 
FROM Sales.SalesOrderDetail sd 
INNER JOIN Production.Product P 
ON sd.ProductID = P.ProductID 
WHERE sd.UnitPrice > 1000 
ORDER BY sd.UnitPrice DESC

/* Get customer numbers
-----------------------------------*/
SELECT p.PersonType
, p.Title
, p.FirstName
, p.MiddleName
, p.LastName
, p.Suffix
, pp.PhoneNumber
, pnt.[Name] AS NumberType
FROM Person.Person p
INNER JOIN Person.PersonPhone pp 
	ON p.BusinessEntityID = pp.BusinessEntityID
INNER JOIN Person.PhoneNumberType pnt 
	ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID 
	AND pnt.PhoneNumberTypeID = 3

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
-- So the LEFT and RIGHT OUTER JOIN logic is opposite of one another
-- FULL OUTER JOIN both sides are preserved with NULL as placeholders for unmatched rows from either side
-----------------------------------------------------------------------------------------------------*/
/* employees with sales for each territory
-- the NULLs represent no sales
-- records in SalesPerson but not in SalesTerritory return NULL as placeholders

-- Note: this is also a multiple join (>2 tables)
-- join order is very important  (see multiple joins)
-------------------------------------------*/
SELECT  p.FirstName,
 p.LastName,
 sp.CommissionPct,
 sp.SalesYTD,
 sp.SalesLastYear,
 sp.Bonus,
 st.TerritoryID,
 st.Name,
 st.[Group],
 st.SalesYTD
FROM Person.Person p
INNER JOIN Sales.Salesperson sp
	ON p.BusinessEntityID = sp.BusinessEntityID
LEFT OUTER JOIN Sales.Salesterritory st 
	ON st.TerritoryID = sp.TerritoryID
ORDER BY st.TerritoryID, p.LastName

/* LEFT OUTER JOIN 
----------------------------------------------------*/
SELECT p.BusinessEntityID
, p.PersonType
, p.NameStyle
, p.Title
, p.FirstName
, p.MiddleName
, p.LastName
, pp.PhoneNumber
, pnt.[Name] AS NumberType
FROM Person.Person p
INNER JOIN Person.PersonPhone pp 
	ON p.BusinessEntityID = pp.BusinessEntityID
LEFT OUTER JOIN Person.PhoneNumberType pnt 
	ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
	AND pnt.PhoneNumberTypeID = 3

/*--RIGHT OUTER JOIN
-- to demonstrate that this is essentially reciproal of the LEFT OUTER JOIN
-- the code is rewritten to preserve the SalesTerritory table
--------------------------------------------------------------*/

SELECT  p.FirstName, 
 p.LastName, 
 sp.CommissionPct,
 sp.SalesYTD,
 sp.SalesLastYear,
 sp.Bonus,
 st.TerritoryID,
 st.Name, st.[Group],
 st.SalesYTD 
FROM Sales.Salesterritory st 
RIGHT OUTER JOIN Sales.Salesperson sp 
	ON st.TerritoryID = sp.TerritoryID 
INNER JOIN Person.Person p
	ON p.BusinessEntityID = sp.BusinessEntityID
ORDER BY st.TerritoryID, p.LastName
GO

/* FULL OUTER JOIN
--both tables preserved
-- NULL as placeholders for unmatched rows from either side
------------------------------------------*/
SELECT soh.AccountNumber
,soh.OrderDate
,cr.ToCurrencyCode
,cr.AverageRate
FROM sales.SalesOrderHeader soh
FULL OUTER JOIN sales.CurrencyRate cr
ON cr.CurrencyRateID = soh.CurrencyRateID

/* DIFFERENCE BETWEEN OUTER JOIN and OUTER APPLY 

-- JOIN treats inputs as sets of inputs (no correlation, no order)
-- APPLY operator applies query logic to each row
-- allows for correlation for multiple columns and rows

-- OUTER APPLY 
-- extends cross apply
-- includes rows from the left table that return an empty set
-- NULLs as placeholders
-- preserves LEFT side
--APPLY operator is required when you have to use a table-valued function in the query, 
-- but it can also be used with inline SELECT statements
----------------------------------------------------------*/


