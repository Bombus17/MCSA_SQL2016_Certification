USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Using Window Functions

-- Window Functions
-- advantages
-- statistical
-- NULLs
-- ORDER BY Clause
-- Running totals **
-- Framing
-- Ranking data (RANK() vs DENSE_RANK()

TODO: finish this script
---------------------------------------------------------------------------------------*/

SELECT ROW_NUMBER() OVER(PARTITION BY ProductSubcategoryID
                    ORDER BY ListPrice, productid) AS rownum
  ,ProductSubcategoryID
  , productid
  , [Name]
  , ListPrice
FROM Production.Product;

-- two products with lowest prices per category
SELECT ProductSubcategoryID, productid, [Name], ListPrice
FROM (SELECT ROW_NUMBER() OVER(PARTITION BY ProductSubcategoryID
                    ORDER BY ListPrice, productid) AS rownum
        ,ProductSubcategoryID
		, productid
		, [Name]
		, ListPrice
      FROM Production.Product) AS D
WHERE rownum <= 2;

-- returning detail as well as aggregates
SELECT custid, orderid, val,
  SUM(val) OVER(PARTITION BY custid) AS custtotal,
  SUM(val) OVER() AS grandtotal
FROM Sales.OrderValues;

-- computing percents of detail out of aggregates
SELECT custid, orderid, val,
  CAST(100.0 * val / SUM(val) OVER(PARTITION BY custid) AS NUMERIC(5, 2)) AS pctcust,
  CAST(100.0 * val / SUM(val) OVER()                    AS NUMERIC(5, 2)) AS pcttotal
FROM Sales.OrderValues;

-- computing running total
SELECT custid, orderid, orderdate, val,
  SUM(val) OVER(PARTITION BY custid
                ORDER BY orderdate, orderid
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runningtotal
FROM Sales.OrderValues;

-- filter running totals that are less than 1000.00
WITH RunningTotals AS
(
  SELECT custid, orderid, orderdate, val,
    SUM(val) OVER(PARTITION BY custid
                  ORDER BY orderdate, orderid
                  ROWS BETWEEN UNBOUNDED PRECEDING
                           AND CURRENT ROW) AS runningtotal
  FROM Sales.OrderValues
)
SELECT *
FROM RunningTotals
WHERE runningtotal < 1000.00;


---------------------------------------------------------------------
-- Window ranking functions
---------------------------------------------------------------------

SELECT custid, orderid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  RANK()       OVER(ORDER BY val) AS rnk,
  DENSE_RANK() OVER(ORDER BY val) AS densernk,
  NTILE(100)   OVER(ORDER BY val) AS ntile100
FROM Sales.OrderValues;

---------------------------------------------------------------------
-- Window offset functions
---------------------------------------------------------------------

-- LAG and LEAD retrieving values from previous and next rows
SELECT custid, orderid, orderdate, val,
  LAG(val)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS prev_val,
  LEAD(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS next_val
FROM Sales.OrderValues;

-- FIRST_VALUE and LAST_VALUE retrieving values from first and last rows in frame
SELECT custid, orderid, orderdate, val,
  FIRST_VALUE(val)  OVER(PARTITION BY custid
                         ORDER BY orderdate, orderid
                         ROWS BETWEEN UNBOUNDED PRECEDING
                                  AND CURRENT ROW) AS first_val,
  LAST_VALUE(val) OVER(PARTITION BY custid
                       ORDER BY orderdate, orderid
                       ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS last_val
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;  

