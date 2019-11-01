USE AdventureWorks2017
GO


/*-----------------------------------------------------

-- USER DEFINED FUNCTIONS

-- A code module that can compute a result or extract and return a subset 
-- of rows from a data source

--SCALAR VALUED UDF
--INLINE TABLE VALUED UDF
--MULTI-STATEMENT TABLE VALUED 

-- See Database Objects folder for further examples
-- Also mssqltips has a good overview of udf
----------------------------------------------------*/

/* SCALAR VALUED FUNCTIONS

-- can be parameterised
-- if no parameters follow the name with a set of parentheses ()
-- parameters can be passed a run time via local variables 
	or with the columns of a data source for a select statement
-- the return clause designated the data type for the returned result
-- see the example in the template explorer for definition
------------------------------------------*/

/* CREATE SCALAR UDF
-----------------------------*/
IF OBJECT_ID (N'dbo.UDF_Get_Line_Total') IS NOT NULL DROP FUNCTION dbo.UDF_Get_Line_Total
GO

CREATE FUNCTION dbo.UDF_Get_Line_Total 
		(	@OrderQty INT
			,@UnitPrice MONEY
			,@UnitPriceDiscount FLOAT
		)
RETURNS DECIMAL(11,4)
AS

BEGIN
	RETURN (( @OrderQty * @UnitPrice) * (1 - @UnitPriceDiscount))

END


/* CALL UDF
-- with parameters
----------------------*/

DECLARE @OrderQty INT,@UnitPrice MONEY,@UnitPriceDiscount FLOAT
SET @OrderQty = 5
SET @UnitPrice = 109.76
SET @UnitPriceDiscount = 0.12

SELECT @OrderQty AS OrderQuantity
, @UnitPrice AS ListPrice
, @UnitPriceDiscount AS LPDiscount
, dbo.UDF_Get_Line_Total (@OrderQty, @UnitPrice, @UnitPriceDiscount) AS [LineTotal];

/* CALL UDF
-- using a data source
----------------------*/

SELECT TOP 5 
       [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[OrderQty]
      ,[ProductID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal] [Line Total from table]
      ,dbo.UDF_Get_Line_Total(OrderQty, UnitPrice, UnitPriceDiscount) [Line Total from function]
FROM [Sales].[SalesOrderDetail]
WHERE [UnitPriceDiscount] = 0
 
UNION
 
SELECT TOP 5 
       [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[OrderQty]
      ,[ProductID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal] [Line Total from table]
   ,dbo.UDF_Get_Line_Total(OrderQty, UnitPrice, UnitPriceDiscount) [Line Total from function]
FROM [Sales].[SalesOrderDetail]
WHERE [UnitPriceDiscount] != 0;

/* INLINE TABLE-VALUED UDF

-- 2 types of TVF (inline and multi statement table valued functions)

-- returns a table data type
-- requires a RETURNS TABLE clause
-- depends on 1 select statement
-- as it returns a table it can be processed as a table
-- can be used in the FROM clause 
-- can accept parameters (unlike views)
-- there is a default parameter here as an example
-----------------------------------------*/
IF OBJECT_ID (N'dbo.UDF_Get_LineTotal_Rowset') IS NOT NULL DROP FUNCTION dbo.UDF_Get_LineTotal_Rowset
GO

CREATE FUNCTION dbo.UDF_Get_LineTotal_Rowset(@UnitPriceDiscount FLOAT=0 )
RETURNS TABLE
AS
RETURN
	(SELECT [SalesOrderDetailID]
		  ,[OrderQty]*[UnitPrice]*(1-unitpricediscount)  AS [LineTotalRowset]
	FROM [Sales].[SalesOrderDetail]
	WHERE unitpricediscount != @UnitPriceDiscount
	)

/* Using the TVF as a table

-- comparing the scalar with the TVF
-- notice rounding due to returned datatypes

-----------------------------------*/
SELECT a.SalesOrderDetailID
   ,LineTotal [Line Total from table] 
   ,b.[LineTotalRowset]
   ,dbo.UDF_Get_Line_Total([OrderQty],[UnitPrice],[UnitPriceDiscount]) [Line Total from scalar-valued udf] 
FROM [Sales].[SalesOrderDetail] a
LEFT JOIN dbo.UDF_Get_LineTotal_Rowset(20) b
	ON a.SalesOrderDetailID = b.SalesOrderDetailID;

/* another way to reference the iTVF
------------------------------------- */
SELECT * 
FROM dbo.UDF_Get_LineTotal_Rowset(DEFAULT) 

/* MULTI-STATEMENT TABLE VALUED UDF

-- returns a rowset populated by 2 or more T-SQL statements within the udf
-- output is a table variable so can be referenced in FROM and JOIN clauses
-- tend to have a performance impact in earlier versions of SQL 
-- return table structure must be defined within the function

------------------------------------*/

DROP TABLE IF EXISTS dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL CONSTRAINT PK_Employees PRIMARY KEY,
  mgrid   INT         NULL
    CONSTRAINT FK_Employees_Employees REFERENCES dbo.Employees,
  empname VARCHAR(25) NOT NULL,
  salary  MONEY       NOT NULL,
  CHECK (empid <> mgrid)
);

INSERT INTO dbo.Employees(empid, mgrid, empname, salary)
  VALUES(1, NULL, 'David', $10000.00),
        (2, 1, 'Eitan', $7000.00),
        (3, 1, 'Ina', $7500.00),
        (4, 2, 'Seraph', $5000.00),
        (5, 2, 'Jiru', $5500.00),
        (6, 2, 'Steve', $4500.00),
        (7, 3, 'Aaron', $5000.00),
        (8, 5, 'Lilach', $3500.00),
        (9, 7, 'Rita', $3000.00),
        (10, 5, 'Sean', $3000.00),
        (11, 7, 'Gabriel', $3000.00),
        (12, 9, 'Emilia' , $2000.00),
        (13, 9, 'Michael', $2000.00),
        (14, 9, 'Didi', $1500.00);

CREATE UNIQUE INDEX idx_unc_mgr_emp_i_name_sal ON dbo.Employees(mgrid, empid)
  INCLUDE(empname, salary);
GO


IF OBJECT_ID (N'dbo.UDF_GetSubtree') IS NOT NULL DROP FUNCTION dbo.UDF_GetSubtree
GO

-- cannot use CREATE OR ALTER to change the function type
GO
CREATE FUNCTION dbo.UDF_GetSubtree (@mgrid AS INT, @maxlevels AS INT = NULL)
RETURNS @Tree TABLE
(
  empid    INT          NOT NULL PRIMARY KEY,
  mgrid    INT          NULL,
  empname  VARCHAR(25)  NOT NULL,
  salary   MONEY        NOT NULL,
  lvl      INT          NOT NULL,
  sortpath VARCHAR(892) NOT NULL,
  INDEX idx_lvl_empid_sortpath NONCLUSTERED(lvl, empid, sortpath)
)
WITH SCHEMABINDING
AS
BEGIN
  DECLARE @lvl AS INT = 0;

  /* insert subtree root node into @Tree
  -----------------------------------------*/
  INSERT INTO @Tree(empid, mgrid, empname, salary, lvl, sortpath)
    SELECT empid, NULL AS mgrid, empname, salary, @lvl AS lvl, '.' AS sortpath
    FROM dbo.Employees
    WHERE empid = @mgrid;

  WHILE @@ROWCOUNT > 0 AND (@lvl < @maxlevels OR @maxlevels IS NULL)
  BEGIN
    SET @lvl += 1;

    /* insert children of nodes from prev level into @Tree 
	--------------------------------------------------------*/
    INSERT INTO @Tree(empid, mgrid, empname, salary, lvl, sortpath)
      SELECT S.empid, S.mgrid, S.empname, S.salary, @lvl AS lvl,
        M.sortpath + CAST(S.empid AS VARCHAR(10)) + '.' AS sortpath
      FROM dbo.Employees AS S
        INNER JOIN @Tree AS M
          ON S.mgrid = M.empid AND M.lvl = @lvl - 1;
  END;
  
  RETURN;
END;
GO

/* test the function 
---------------------*/
SELECT empid, REPLICATE(' | ', lvl) + empname AS emp,
  mgrid, salary, lvl, sortpath
FROM dbo.UDF_GetSubtree(3, NULL) AS T
ORDER BY sortpath;
GO

