USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Using Window Functions

-- Window Functions
-- Aggregate Window Functions: SUM(), MAX(), MIN(), AVG(), COUNT() 
					N.B. COUNT DISTINT is not valid here
-- advantages
-- statistical
-- NULLs
-- ORDER BY Clause
-- Running totals 
-- Ranking Window Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), NTILE()
							CUME_DIST(), PERCENT_RANK()
-- Window OFFSET functions: LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE() ** know the difference
-- FRAMING: see definitions at the end of this script


---------------------------------------------------------------------------------------*/

/* WINDOWN FUNCTIONS
--These operate on a set of rows and return a single aggregated value for each row.
--UNLIKE IN GROUP BY: Window functions do not cause rows to become grouped into a single output row
--, the rows retain their separate identities and an aggregated value will be added to each row
--The term Window describes the set of rows in the database on which the function will operate

--SYNTAX
	window_function ( [ ALL ] expression ) 
	OVER ( [ PARTITION BY partition_list ] [ ORDER BY order_list] )


WINDOW_FUNCTION: Specify the name of the window function 
ALL: ALL is an optional keyword. When you will include ALL it will count all values including duplicate ones. 
DISTINCT is not supported in window functions 
Expression: The target column or expression that the functions operates on. In other words
	, the name of the column for which we need an aggregated value. 
	For example, a column containing order amount so that we can see total orders received. 
OVER: Specifies the window clauses for aggregate functions 
PARTITION BY partition_list : Defines the window (set of rows on which window function operates) for window functions
	We need to provide a field or list of fields for the partition after PARTITION BY clause
	Multiple fields need be separated by a comma as usual. If PARTITION BY is not specified, 
	grouping will be done on entire table and values will be aggregated accordingly. 
ORDER BY order_list : Sorts the rows within each partition. If ORDER BY is not specified, ORDER BY uses the entire table 
----------------------------------------*/


/* ROW_NUMBER
-- Assigns a unique row number to each record 
-- The row number will be reset for each partition if PARTITION BY is specified
-----------------------------------------------------*/
SELECT ROW_NUMBER() OVER(PARTITION BY ProductSubcategoryID
                    ORDER BY ListPrice, productid) AS RowNum
  , ProductSubcategoryID
  , productid
  , [Name]
  , ListPrice
FROM Production.Product;

/* two products with lowest prices per category
-------------------------------------------------*/


/*  Return Total Due per order per Customer
----------------------------------------*/
SELECT [CustomerID]
	, [SalesOrderID]
	, [TotalDue]
	,SUM([TotalDue]) OVER(PARTITION BY [CustomerID]) AS CustomerTotal
	,SUM([TotalDue]) OVER() AS GrandTotal
FROM [Sales].[SalesOrderHeader];

/* computing percents of detail out of aggregates
-----------------------------------------------------*/
SELECT [CustomerID]
	,[SalesOrderID]
	,[TotalDue]
	,CAST(100.0 * [TotalDue] / SUM([TotalDue]) OVER(PARTITION BY [CustomerID]) AS NUMERIC(5, 2)) AS Cust_PCT
	,CAST(100.0 * [TotalDue] / SUM([TotalDue]) OVER()                    AS NUMERIC(5, 2)) AS Total_PCT
FROM [Sales].[SalesOrderHeader];

/* Calculate a running total
-- Runnig total aggregated by CustomerID
-----------------------------*/
SELECT [CustomerID]
	, [SalesOrderID]
	, OrderDate
	, [TotalDue]
	,SUM([TotalDue]) OVER(PARTITION BY [CustomerID]
                ORDER BY [OrderDate], [SalesOrderID]
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS RunningTotal
FROM [Sales].[SalesOrderHeader];

/* Use a CTE to filter running totals that are less than 1000.00
-----------------------------------------------------------------*/
	WITH RunningTotals AS
		(
		SELECT [CustomerID]
			, [SalesOrderID]
			, OrderDate
			, [TotalDue]
			,SUM([TotalDue]) OVER(PARTITION BY [CustomerID]
						ORDER BY [OrderDate], [SalesOrderID]
						ROWS BETWEEN UNBOUNDED PRECEDING
								 AND CURRENT ROW) AS RunningTotal
		FROM [Sales].[SalesOrderHeader]
		)
	SELECT *
	FROM RunningTotals
	WHERE runningtotal < 1000.00;


/*---------------------------------------------------------------------
-- Window ranking functions

--Just as Window aggregate functions aggregate the value of a specified field, 
--RANKING functions will rank the values of a specified field and categorize them according to their rank

-- RANK(): assigns unique rank to each record based on a specified value
		If two records have the same value the same rank to both records by skipping the next rank.
-- DENSE_RANK(): identical to the RANK() function except that it does not skip any ranks
		two identical records are found the same rank is assigned to both records but the next rank isn't skipped
-- NTILE: Allows us to identify what percentile (or any other subdivision) a given row falls into
---------------------------------------------------------------------*/

SELECT [CustomerID]
	,[SalesOrderID]
	,[TotalDue]
	,ROW_NUMBER() OVER(ORDER BY [TotalDue]) AS RowNum
	,RANK()       OVER(ORDER BY [TotalDue]) AS RNK
	,DENSE_RANK() OVER(ORDER BY [TotalDue]) AS DENSE_RNK
	,NTILE(25)   OVER(ORDER BY [TotalDue]) AS NTILE_25
	,NTILE(100)   OVER(ORDER BY [TotalDue]) AS NTILE_100
	,PERCENT_RANK() OVER(ORDER BY  [TotalDue]) AS PCT_RNK -- always returns 0 in first row
	,ROUND(CUME_DIST() OVER(ORDER BY [TotalDue]),4) AS CUMEDIST
FROM [Sales].[SalesOrderHeader];

/*
-- Window offset functions

--LAG: allows to access data from the previous row in the same result set without use of joins
--LEAD: allows to access data from the next row in the same result set without use of joins

--These functions allow us to identify first and last record within a partition or entire table if PARTITION BY is not specified
--The  ORDER BY clause is mandatory for each one
--FIRST_VALUE: 
--LAST_VALUE:
---------------------------------------------------------------------*/

---- LAG and LEAD retrieving values from previous and next rows

SELECT [CustomerID]
		,[SalesOrderID]
		,[TotalDue]
		,LAG([TotalDue])  OVER(PARTITION BY [CustomerID]
						ORDER BY orderdate, [SalesOrderID]) AS Prev_Val
		,LEAD([TotalDue]) OVER(PARTITION BY [CustomerID]
						ORDER BY orderdate, [SalesOrderID]) AS Next_Val
FROM [Sales].[SalesOrderHeader];

/*  FIRST_VALUE and LAST_VALUE retrieving values from first and last rows in frame
-----------------------------------------------------------------------------*/
SELECT [CustomerID]
	, [SalesOrderID]
	, [OrderDate]
	, [TotalDue]
  ,FIRST_VALUE([TotalDue])  OVER(PARTITION BY [CustomerID]
							ORDER BY [OrderDate], SalesOrderID
							ROWS BETWEEN UNBOUNDED PRECEDING
                                  AND CURRENT ROW) AS First_Val
  ,LAST_VALUE([TotalDue]) OVER(PARTITION BY [CustomerID]
							ORDER BY [OrderDate], SalesOrderID
							ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS Last_Val
FROM [Sales].[SalesOrderHeader]
ORDER BY [CustomerID], [OrderDate], [SalesOrderID];  

/* FRAMING

ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW: Start at row 1 of the partition and include rows up to the current row.
ROWS UNBOUNDED PRECEDING: Start at row 1 of the partition and include rows up to the current row.
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING: Start at the current row and include rows up to the end of the partition.
ROWS BETWEEN N PRECEDING AND CURRENT ROW.: Start at a specified number of rows before the current row and 
			include rows up to the current row.
ROWS BETWEEN CURRENT ROW AND N FOLLOWING: Start at the current row and include rows up to a specified number of rows 
			following the current row.
ROWS BETWEEN N PRECEDING AND N FOLLOWING: Start at a specified number of rows before the current row and 
		include a specified number of rows following the current row. Yes, the current row is also included!

The ROWS or RANGE specifies the type of relationship between the current row and frame rows.
ROWS: the offsets of the current row and frame rows are row numbers.
RANGE: the offset of the current row and frame rows are row values
-----------------------------------------------------------*/

SELECT CustomerID
	,SalesOrderID
	,CAST(OrderDate AS Date) AS OrderDate
	,TotalDue
	,SUM(TotalDue) OVER(ORDER BY OrderDate
					ROWS UNBOUNDED PRECEDING) AS RunningTotal
	,SUM(TotalDue) OVER(ORDER BY OrderDate) AS DefFrameRunningTotal
	,FIRST_VALUE(SalesOrderID) OVER(ORDER BY OrderDate) AS FirstOrder
	,LAST_VALUE(SalesOrderID) OVER(ORDER BY OrderDate
					ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS LastOrder
	, LAST_VALUE(SalesOrderID) OVER(ORDER BY OrderDate) AS DefFrameLastOrder
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29586
ORDER BY OrderDate;