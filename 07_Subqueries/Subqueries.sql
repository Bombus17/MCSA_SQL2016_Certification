USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: SUB QUERIES

-- self contained 
-- scalar sub query
-- multi-value sub query
-- correlated 
-- ANY and SOME predicates
-- EXISTS
-- NOT EXISTS
-- optimisation
-- nested sub queries

TODO: finish this script
--------------------------------------------------------------------------
-------------*/

/* All products that have been ordered
--------------------------------------*/

SELECT ProductID, [Name] AS ProductName, Color, ListPrice
FROM Production.Product
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail);

/* Products that have yet to be ordered
-- and are not display/0 price products
---------------------------------------*/
SELECT ProductID, [Name] AS ProductName
, ISNULL(Color, '')AS Colour
, ListPrice
FROM Production.Product
WHERE ProductID NOT IN (SELECT ProductID 
						FROM Sales.SalesOrderDetail
						WHERE ProductID IS NOT NULL)
AND ListPrice > 0
ORDER BY ProductID;

/* scalar subquery 
-- highest value order 
-- cheapest (non display) product
---------------------------------------------------------------------*/
SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue = (SELECT MAX(TotalDue) FROM Sales.SalesOrderHeader);

SELECT productid, [Name], ListPrice
FROM Production.Product
WHERE ListPrice = (SELECT MIN(ListPrice) FROM Production.Product
					WHERE ListPrice != 0);


/* MULTI VALUE SUB QUERY 
------------------------*/

--Return all employee born after 1980 and use that list with the IN keyword to get the Employee names
-- from the Person table

SELECT Firstname + ' ' + Lastname Employee
FROM Person.Person
WHERE Person.BusinessEntityID IN
	(SELECT BusinessEntityID
	 FROM HumanResources.Employee
	 WHERE Year(BirthDate)>1980)
ORDER BY LastName, FirstName;

-- all products listed as a bike
SELECT productid, [Name], listPrice 
FROM Production.Product
WHERE ProductSubcategoryID IN
  (SELECT ProductCategoryID
   FROM Production.ProductCategory
   WHERE [Name] = N'Bikes');


/*  here we use a table-value subquery...also known as a table expression
-- to find the last SalesOrderID for each year
-- you can run the sub query separately as it's un correlated
-------------------------------------------------------*/
SELECT OrderYear, MAX(SalesOrderID) LastOrderID
FROM
	(SELECT SalesOrderID, Year(OrderDate) OrderYear -- Run this inner query separately 
	 FROM Sales.SalesOrderHeader)as D               -- to see the table being returned
GROUP BY OrderYear 
ORDER BY OrderYear;

/* CORRELATED SUBQUERY 
-- Sales Assistants with high sales
----------------------------------------------*/
-- FIRST QUERY
SELECT DISTINCT p.BusinessEntityID
	, p.FirstName + ' ' + p.LastName AS [Name]
FROM Person.Person p
INNER JOIN sales.SalesOrderHeader s
	ON p.BusinessEntityID=s.SalesPersonID
WHERE s.TotalDue>110000;

/* WRITTEN AS A CORRELATED SUBQUERY 
--INNER QUERY: runs first and locates a matching record
--OUTER QUERY: runs using the record found, then the inner query 
--runs again searching for another match...until all records are retrieved 
-----------------------------------------------------------------------------*/
SELECT p.BusinessEntityID, FirstName + ' ' + LastName Salesperson 
FROM Person.Person p
WHERE EXISTS (SELECT s.SalesPersonID FROM Sales.Salesorderheader s -- this query cannot be run independently and is therefore correlated to the outer query
				WHERE TotalDue>110000
				and p.BusinessEntityID=s.SalesPersonID);


-- products with minimum unitprice per category
SELECT ProductSubcategoryID, productid, [Name], ListPrice
FROM Production.Product AS P1
WHERE ListPrice =
  (SELECT MIN(ListPrice)
   FROM Production.Product AS P2
   WHERE P2.ProductSubcategoryID = P1.ProductSubcategoryID);

/* use correlated sub query to find the nth highest salary
	for each record processed by the outer query the inner query returns 
	how many records has a value less than the value stated 
----------------------------------------------------------------------------*/
DECLARE @Nth INT = 4

SELECT CASE @Nth
		WHEN 2 THEN 'Second Highest salary'
		ELSE 
		CAST(@Nth AS char(3)) + 'th Highest salary' 
		END AS Qry
	,Salary
FROM Employees e
WHERE @Nth=(SELECT COUNT(DISTINCT Salary) 
         FROM Employees p
         WHERE e.Salary<=p.Salary)

/* ANY, ALL and SOME 

---------------------------------------*/

-- ALL
-- alternative solution for products with minimum price
SELECT productid, [Name], ListPrice
FROM Production.Product
WHERE ListPrice <= ALL (SELECT ListPrice FROM Production.Product
						WHERE ListPrice > 0)
AND ListPrice > 0;

-- ANY / SOME
-- products with price that is not the minimum
SELECT ProductID, [Name], ListPrice
FROM Production.Product
WHERE ListPrice > ANY (SELECT ListPrice FROM Production.Product);

/* EXIST and NOT EXISTS in sub queries
-- note think about INTERSECT and EXCEPT here too. 
-- review those queries and look at performance
-----------------------------------------------*/
-- customers who placed an order on February 18, 2012
SELECT CustomerID, AccountNumber
FROM Sales.Customer AS C
WHERE EXISTS (SELECT *
			FROM Sales.SalesOrderHeader AS O
			WHERE O.CustomerID = C.CustomerID
			AND O.orderdate = '20120218');

-- customers who did not place an order on February 18, 2012
SELECT CustomerID, AccountNumber
FROM Sales.Customer AS C
WHERE NOT EXISTS (SELECT *
					FROM Sales.SalesOrderHeader AS O
					WHERE O.CustomerID = C.CustomerID
					AND O.orderdate = '20120218');
