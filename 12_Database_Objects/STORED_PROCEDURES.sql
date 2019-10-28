USE WideWorldImporters
GO


/* STORED PROCEDURES

--CREATE STORED PROCEDURE
-- ALTER SPROC
-- USING TRANSACTIONS
-- Execution context
-- Permission
-- OUTPUT parameters
-- Using CURSORS

TODO: Check this
-------------------------------------*/


-- simple procedure that handles dynamic search conditions
CREATE OR ALTER PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @orderdate AS DATE = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL
AS

SET XACT_ABORT, NOCOUNT ON;

SELECT orderid, orderdate, shippeddate, custid, empid, shipperid
FROM Sales.Orders
WHERE (orderid   = @orderid   OR @orderid   IS NULL)
  AND (orderdate = @orderdate OR @orderdate IS NULL)
  AND (custid    = @custid    OR @custid    IS NULL)
  AND (empid     = @empid     OR @empid     IS NULL);
GO

-- test procedure
EXEC dbo.GetOrders @orderdate = '20151111', @custid = 85;
GO
EXEC dbo.GetOrders DEFAULT, '20151111', 85, DEFAULT;
GO
EXEC dbo.GetOrders @orderid = 42;
GO

---------------------------------------------------------------------
-- Stored procedures and dynamic SQL
---------------------------------------------------------------------

-- create prcoedure with dynamic SQL
CREATE OR ALTER PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @orderdate AS DATE = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL
AS

SET XACT_ABORT, NOCOUNT ON;

DECLARE @sql AS NVARCHAR(MAX) = N'SELECT orderid, orderdate, shippeddate, custid, empid, shipperid
FROM Sales.Orders
WHERE 1 = 1'
  + CASE WHEN @orderid   IS NOT NULL THEN N' AND orderid   = @orderid  ' ELSE N'' END
  + CASE WHEN @orderdate IS NOT NULL THEN N' AND orderdate = @orderdate' ELSE N'' END
  + CASE WHEN @custid    IS NOT NULL THEN N' AND custid    = @custid   ' ELSE N'' END
  + CASE WHEN @empid     IS NOT NULL THEN N' AND empid     = @empid    ' ELSE N'' END
  + N';'

EXEC sys.sp_executesql
  @stmt = @sql,
  @params = N'@orderid AS INT, @orderdate AS DATE, @custid AS INT, @empid AS INT',
  @orderid   = @orderid,
  @orderdate = @orderdate,
  @custid    = @custid,
  @empid     = @empid;
GO

-- execute procedure
EXEC dbo.GetOrders @orderdate = '20151111', @custid = 85;

-- create temporary principal
CREATE LOGIN login1 WITH PASSWORD = 'J345#$)thb';  
GO  
CREATE USER user1 FOR LOGIN login1;  
GO  

-- grant permission to user1 to execute procedure
GRANT EXEC ON dbo.GetOrders TO user1;
GO

-- display current execution context
SELECT SUSER_NAME() AS [login], USER_NAME() AS [user];  

-- set the execution context to login1
EXECUTE AS LOGIN = 'login1';  

-- display current execution context again
SELECT SUSER_NAME() AS [login], USER_NAME() AS [user];  

-- try to execute procedure
EXEC dbo.GetOrders @orderdate = '20151111', @custid = 85;

-- revert back to original execution context
REVERT;
GO

-- alter prcoedure to execute as owner
CREATE OR ALTER PROC dbo.GetOrders
  @orderid   AS INT  = NULL,
  @orderdate AS DATE = NULL,
  @custid    AS INT  = NULL,
  @empid     AS INT  = NULL
WITH EXECUTE AS OWNER
AS

SET XACT_ABORT, NOCOUNT ON;

DECLARE @sql AS NVARCHAR(MAX) = N'SELECT orderid, orderdate, shippeddate, custid, empid, shipperid
FROM Sales.Orders
WHERE 1 = 1'
  + CASE WHEN @orderid   IS NOT NULL THEN N' AND orderid   = @orderid  ' ELSE N'' END
  + CASE WHEN @orderdate IS NOT NULL THEN N' AND orderdate = @orderdate' ELSE N'' END
  + CASE WHEN @custid    IS NOT NULL THEN N' AND custid    = @custid   ' ELSE N'' END
  + CASE WHEN @empid     IS NOT NULL THEN N' AND empid     = @empid    ' ELSE N'' END
  + N';'

EXEC sys.sp_executesql
  @stmt = @sql,
  @params = N'@orderid AS INT, @orderdate AS DATE, @custid AS INT, @empid AS INT',
  @orderid   = @orderid,
  @orderdate = @orderdate,
  @custid    = @custid,
  @empid     = @empid;
GO

-- set the execution context to login1
EXECUTE AS LOGIN = 'login1';  

-- try to execute procedure
EXEC dbo.GetOrders @orderdate = '20151111', @custid = 85;

-- revert back to original execution context
REVERT;

---------------------------------------------------------------------
-- Using output parameters and modifying data
---------------------------------------------------------------------

-- create table dbo.MySequences
DROP TABLE IF EXISTS dbo.MySequences;
GO
CREATE TABLE dbo.MySequences
(
  seqname VARCHAR(128) NOT NULL
    CONSTRAINT PK_MySequences PRIMARY KEY,
  val INT NOT NULL
    CONSTRAINT DFT_MySequences_val DEFAULT(0)
);
GO

-- create sequence for invoices
INSERT INTO dbo.MySequences(seqname, val) VALUES('SEQINVOICES', 0);
GO

-- create proc that returns a new sequence value for input sequence
CREATE OR ALTER PROC dbo.GetSequenceValue
  @seqname AS VARCHAR(128),
  @val     AS INT OUTPUT
AS

SET XACT_ABORT, NOCOUNT ON;

UPDATE dbo.MySequences
  SET @val = val += 1
WHERE seqname = @seqname;

IF @@ROWCOUNT = 0
  THROW 51001, 'Specified sequence was not found.', 1;
GO

-- request a new value
DECLARE @newinvoicenumber AS INT;
EXEC dbo.GetSequenceValue @seqname = 'SEQINVOICES', @val = @newinvoicenumber OUTPUT;
SELECT @newinvoicenumber AS newinvoicenumber;
GO

-- try with a sequence that doesn't exist
DECLARE @newinvoicenumber AS INT;
EXEC dbo.GetSequenceValue @seqname = 'NOSUCHSEQUENCE', @val = @newinvoicenumber OUTPUT;
SELECT @newinvoicenumber AS newinvoicenumber;
GO

---------------------------------------------------------------------
-- Using cursors
---------------------------------------------------------------------

-- create and populate table Transactions
DROP TABLE IF EXISTS dbo.Transactions;
GO
CREATE TABLE dbo.Transactions
(
  txid INT NOT NULL CONSTRAINT PK_Transactions PRIMARY KEY,
  qty  INT NOT NULL,
  depletionqty INT NULL
);
GO

TRUNCATE TABLE dbo.Transactions;
INSERT INTO dbo.Transactions(txid, qty)
  VALUES(1,2),(2,5),(3,4),(4,1),(5,10),(6,3),(7,1),(8,2),(9,1),(10,2),(11,1),(12,9);
GO

-- procedure that handles task that computes cumulative quantities in a container,
-- with the container depleted as soon as it exceeds a certain input quantity
-- the goal is to write the depletion quantity into the column depletionqty
-- see challenge at http://sqlmag.com/t-sql/t-sql-challenges-replenishing-and-depleting-quantities
CREATE OR ALTER PROC dbo.ComputeDepletionQuantities
  @maxallowedqty AS INT
AS

SET XACT_ABORT, NOCOUNT ON;

UPDATE dbo.Transactions
  SET depletionqty = NULL
WHERE depletionqty IS NOT NULL;

DECLARE @qty AS INT, @sumqty AS INT = 0;

DECLARE C CURSOR FOR
  SELECT qty
  FROM dbo.Transactions
  ORDER BY txid;

OPEN C;

FETCH NEXT FROM C INTO @qty;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sumqty += @qty;

  IF @sumqty > @maxallowedqty
  BEGIN
    UPDATE dbo.Transactions
      SET depletionqty = @sumqty
    WHERE CURRENT OF C;

    SET @sumqty = 0;
  END;

  FETCH NEXT FROM C INTO @qty;
END;

CLOSE C;

DEALLOCATE C;

SELECT txid, qty, depletionqty,
  SUM(qty - ISNULL(depletionqty, 0))
    OVER(ORDER BY txid ROWS UNBOUNDED PRECEDING) AS totalqty
FROM dbo.Transactions
ORDER BY txid;
GO

-- test proc with @maxallowedqty = 5
EXEC dbo.ComputeDepletionQuantities @maxallowedqty = 5;

-- cleanup
DROP USER IF EXISTS user1;
GO
DROP LOGIN login1;
GO
DROP PROC IF EXISTS dbo.GetOrders, dbo.GetSequenceValue, dbo.ComputeDepletionQuantities;
DROP TABLE IF EXISTS dbo.MySequences, dbo.Transactions;
GO
