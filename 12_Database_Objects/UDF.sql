USE AdventureWorks2017
GO

/*   USER-DEFINED FUNCTIONS

-- scalar UDF
-- table valued UDF
-- invoke UDF
-- create UDF with SCHEMABINDING
-- Inline table valued UDF
-- multi statement UDF

TODO: Test inline TVF and review MS udf
------------------------------------------*/

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

---------------------------------------------------------------------
-- Scalar user-defined functions
---------------------------------------------------------------------

-- function can be based on multiple statements and involve queries
CREATE OR ALTER FUNCTION dbo.SubtreeTotalSalaries(@mgr AS INT)
  RETURNS MONEY
WITH SCHEMABINDING
AS
BEGIN
  DECLARE @totalsalary AS MONEY;

  WITH EmpsCTE AS
  (
    SELECT empid, salary
    FROM dbo.Employees
    WHERE empid = @mgr

    UNION ALL

    SELECT S.empid, S.salary
    FROM EmpsCTE AS M
      INNER JOIN dbo.Employees AS S
        ON S.mgrid = M.empid
  )
  SELECT @totalsalary = SUM(salary)
  FROM EmpsCTE;

  RETURN @totalsalary;
END;
GO

-- test function
SELECT dbo.SubtreeTotalSalaries(8) AS subtreetotal;
GO

SELECT SubtreeTotalSalaries(8) AS subtreetotal;
GO

-- test function in a query
SELECT empid, mgrid, empname, salary,
  dbo.SubtreeTotalSalaries(empid) AS subtreetotal
FROM dbo.Employees;
GO

-- most built-in functions are invoked once per query; NEWID is an exception
SELECT orderid, SYSDATETIME() AS [SYSDATETIME], RAND() AS [RAND], NEWID() AS [NEWID]
FROM Sales.Orders;
GO

-- definition of function MySYSDATETIME
CREATE OR ALTER FUNCTION dbo.MySYSDATETIME() RETURNS DATETIME2
AS
BEGIN
  RETURN SYSDATETIME();
END;
GO

-- not allowed to invoke side-effecting functions
CREATE OR ALTER FUNCTION dbo.MyRAND() RETURNS FLOAT
AS
BEGIN
  RETURN RAND();
END;
GO

-- can circumvent restriction by using a view
CREATE OR ALTER VIEW dbo.VRAND
AS

SELECT RAND() AS myrand;
GO

CREATE OR ALTER FUNCTION dbo.MyRAND() RETURNS FLOAT
AS
BEGIN
  RETURN (SELECT myrand FROM dbo.VRAND);
END;
GO

-- UDF invoked per row
SELECT orderid, dbo.MySYSDATETIME() AS mysysdatetime, dbo.MyRAND() AS myrand
FROM Sales.Orders;
GO

-- create function without SCHEMBINDING
CREATE OR ALTER FUNCTION dbo.ENDOFYEAR(@dt AS DATE) RETURNS DATE
AS
BEGIN
  RETURN DATEFROMPARTS(YEAR(@dt), 12, 31);
END;
GO

-- try to create table
DROP TABLE IF EXISTS dbo.T1;
GO
CREATE TABLE dbo.T1
(
  keycol INT NOT NULL IDENTITY CONSTRAINT PK_T1 PRIMARY KEY,
  dt DATE NOT NULL,
  dtendofyear AS dbo.ENDOFYEAR(dt) PERSISTED
);
GO

-- recreate UDF with SCHEMABINDING
CREATE OR ALTER FUNCTION dbo.ENDOFYEAR(@dt AS DATE)
  RETURNS DATE
WITH SCHEMABINDING
AS
BEGIN
  RETURN DATEFROMPARTS(YEAR(@dt), 12, 31);
END;
GO

-- try again to create table
CREATE TABLE dbo.T1
(
  keycol INT NOT NULL IDENTITY CONSTRAINT PK_T1 PRIMARY KEY,
  dt DATE NOT NULL,
  dtendofyear AS dbo.ENDOFYEAR(dt) PERSISTED
);
GO

---------------------------------------------------------------------
-- Inline table-valued user-defined functions
---------------------------------------------------------------------

-- definition of function GetPage
CREATE OR ALTER FUNCTION dbo.GetPage(@pagenum AS BIGINT, @pagesize AS BIGINT)
  RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  WITH C AS
  (
    SELECT ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum,
      orderid, orderdate, custid, empid
    FROM Sales.Orders
  )
  SELECT rownum, orderid, orderdate, custid, empid
  FROM C
  WHERE rownum BETWEEN (@pagenum - 1) * @pagesize + 1 AND @pagenum * @pagesize;
GO

-- test function
SELECT rownum, orderid, orderdate, custid, empid
FROM dbo.GetPage(3, 12) AS T;
GO

-- alternative definition of function GetPage
CREATE OR ALTER FUNCTION dbo.GetPage(@pagenum AS BIGINT, @pagesize AS BIGINT)
  RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  SELECT ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum,
    orderid, orderdate, custid, empid
  FROM Sales.Orders
  ORDER BY orderdate, orderid
  OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

-- test function
SELECT rownum, orderid, orderdate, custid, empid
FROM dbo.GetPage(3, 12) AS T;

-- return subtree; use NULL as manager of root
DROP FUNCTION IF EXISTS dbo.GetSubtree;
GO
CREATE FUNCTION dbo.GetSubtree(@mgr AS INT, @maxlevels AS INT = NULL)
  RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  WITH EmpsCTE AS
  (
    SELECT empid, CAST(NULL AS INT) AS mgrid, empname, salary, 0 as lvl,
      CAST('.' AS VARCHAR(900)) AS sortpath
    FROM dbo.Employees
    WHERE empid = @mgr

    UNION ALL

    SELECT S.empid, S.mgrid, S.empname, S.salary, M.lvl + 1 AS lvl,
      CAST(M.sortpath + CAST(S.empid AS VARCHAR(10)) + '.' AS VARCHAR(900)) AS sortpath
    FROM EmpsCTE AS M
      INNER JOIN dbo.Employees AS S
        ON S.mgrid = M.empid
        AND (M.lvl < @maxlevels OR @maxlevels IS NULL)
  )
  SELECT empid, mgrid, empname, salary, lvl, sortpath
  FROM EmpsCTE;
GO

-- test
SELECT empid, REPLICATE(' | ', lvl) + empname AS emp,
  mgrid, salary, lvl, sortpath
FROM dbo.GetSubtree(3, NULL) AS T
ORDER BY sortpath;
GO

---------------------------------------------------------------------
-- Multistatement table-valued user-defined functions
---------------------------------------------------------------------

-- definition of GetSubtree function
DROP FUNCTION IF EXISTS dbo.GetSubtree;
-- cannot use CREATE OR ALTER to change the function type
GO
CREATE FUNCTION dbo.GetSubtree (@mgrid AS INT, @maxlevels AS INT = NULL)
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

  -- insert subtree root node into @Tree
  INSERT INTO @Tree(empid, mgrid, empname, salary, lvl, sortpath)
    SELECT empid, NULL AS mgrid, empname, salary, @lvl AS lvl, '.' AS sortpath
    FROM dbo.Employees
    WHERE empid = @mgrid;

  WHILE @@ROWCOUNT > 0 AND (@lvl < @maxlevels OR @maxlevels IS NULL)
  BEGIN
    SET @lvl += 1;

    -- insert children of nodes from prev level into @Tree
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

-- test
SELECT empid, REPLICATE(' | ', lvl) + empname AS emp,
  mgrid, salary, lvl, sortpath
FROM dbo.GetSubtree(3, NULL) AS T
ORDER BY sortpath;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1;

DROP VIEW IF EXISTS dbo.VRAND;

DROP FUNCTION IF EXISTS dbo.MySYSDATETIME, dbo.MyRAND, dbo.ENDOFYEAR,
  dbo.SubtreeTotalSalaries, dbo.GetPage, dbo.GetSubtree;

DROP TABLE IF EXISTS dbo.Employees;