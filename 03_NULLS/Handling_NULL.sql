USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: handling NULLs in T-SQL 

-- NULL in predicates
-- NULL as placeholders (see Using_Joins.sql)

-- ISNULL
-- COALESCE
-- Differences betweeen ISNULL and COALESCE
-- Nullability of result column when using ISNULL or COALESCE in a SELECT INTO statement
-- ISNULL and COALESCE: Performance when using sub queries

-- NULLIF
-- CONCAT and NULL
-- Date Time and NULL
-- How NULLs are handled in COUNT(*)
-- sorting data and NULL
-- comparing NULL (e.g. INTERSECT and EXCEPT)
-- using NULL in aggregate functions (see Aggregate_Functions.sql)
-- using NULL in PIVOT (see PIVOT.sql)
-- using NULL in UNPIVOT(see UNPIVOT.sql)
-- Using NULL in joins (OUTER JOIN)
-- Using NULL with the OUTER APPLY operator

TODO: finish this script
---------------------------------------------------------------------------------------*/

/* NULL in predicates when joining tables and queries

-- comparing NULL with equality based predicate returns logical value UNKNOWN
-- therefore use ISNULL and an operator
-- applying manipulation to join columns breaks the ordering property of the data
-- the optimiser is affected as a result as it can't rely on indexing
-- there is a performance impact

-----------------------------------------------------------------------------------*/

/* ISNULL and COALESCE functions and their differences

-- COALESCE accepts a list of expressions, returning the first non NULL value or NULL if all are NULLs
-- ISNULL accepts two expressions and replaces the NULL with another non NULL expression
-- there are differences between them
1. ISNULL supports only 2 parameters, COALESCE supports many
2. ISNULL is proprietary T-SQL, COALESCE is defined by the ISO/ANSI standard
3. Return data types are calibrated differently
-- ISNULL
	-- If the first input has a data type the return assumes this data type
	-- If the first input is NULL and the second input has a data type, this data type is returned
	-- If both inputs are untyped NULL literals the result data type is INT
	-- SELECT INTO statement: if any of the input expressions in nonnullable, the result columnn is defined as NOT NULL
	-- Sub Queries: see example below

-- COALESCE
	-- If at least one input has a type, the result type is the type with the highest precedence
	-- If all inputs are untyped NULL literals, an error is returned
	-- SELECT INTO statement: when all inputs are nonnullable, the result column is defined as NOT NULL; otherwise it allows NULL
	-- Sub Queries: see example below
--------------------------------------------------*/

DECLARE @AA AS INT = NULL
, @BB AS INT = 1902
, @CC AS INT = 42

SELECT ISNULL(@AA, @BB);
SELECT COALESCE(@AA, @BB, @CC);

DECLARE
  @x AS VARCHAR(3) = NULL,
  @y AS VARCHAR(10) = '1234567890';

SELECT ISNULL(@x, @y) AS ISNULLxy, COALESCE(@x, @y) AS COALESCExy;
GO

SELECT ISNULL('1a2b', 1234) AS ISNULLstrnum;
GO
SELECT COALESCE('1a2b', 1234) AS COALESCEstrnum;
GO


/* ISNULL and COALESCE with Sub Queries

-- when comparing ISNULL((<subquery>,0) with COALESCE((<subquery,0)
-- ISNULL evaluates the subquery only once
-- if the result is not NULL then it returns the result
-- If it is NULL, it evaluates the second input and returns the result

-- COALESCE translates the query as follows:
-- CASE WHEN (<subquery>) IS NOT NULL THEN (<subquery>) ELSE 0 END

-- If the result of the execution of the subquery in the WHEN caluse isn't NULL, SQL executes it a second time in the THEN clause

-- So ISNULL has a performance advantage of COALESCE when using subqueries
----------------------------------------------------------------------------------*/


/* NULLIF function
-- accepts two input expressions
-- returns NULL if they are equal
-- returns the first if they are not
---------------------------------------------*/

DECLARE @X AS INT = 25
DECLARE @Y AS INT = 25
DECLARE @Z AS INT = 75

SELECT NULLIF(@X, @X); -- returns NULL if they're equal
SELECT NULLIF(@Y, @Z); -- returns the first if they're not equal

/* CONCAT functon
-- substitutes NULL with an empty string
-----------------------------------------*/
SELECT [AddressLine1]
      ,[AddressLine2]
      ,[City]
      ,[StateProvinceID]
	  , CONCAT([AddressLine1], N', ', [AddressLine2],N', ', [City],N', ',[StateProvinceID]) AS FullAddress
FROM [Person].[Address];

/* NULL and aggregate functions
-- Aggregate functions ignore NULL inputs when applied to an expression
-- COUNT never returns NULL but returns a number or 0
-- for all other funtions if the data set contains no rows, or contains only rows with nulls as arguments to the aggregate function,
---then the function returns null.

-------------------------------------------------------------------*/
/* find all products without a colour 
 -- IS NULL never = NULL
*/

SELECT ProductID
	, [Name] AS ProductName
	, Color
FROM Production.Product
WHERE Color IS NULL;

/* Products which aren't Silver */
SELECT ProductID
	, [Name] AS ProductName
	, Color
FROM Production.Product
WHERE Color IS NULL OR Color != 'Silver';

-- could also use
SELECT ProductID
	, [Name] AS ProductName
	, Color
FROM Production.Product
WHERE ISNULL(Color, '')  != 'Silver';


-- nullability of result
DROP TABLE IF EXISTS dbo.TestNULLs;
GO
SELECT empid,
  ISNULL(region, country) AS ISNULLregioncountry,
  COALESCE(region, country) AS COALESCEregioncountry
INTO dbo.TestNULLs
FROM HR.Employees;

SELECT
  COLUMNPROPERTY(OBJECT_ID('dbo.TestNULLs'), 'ISNULLregioncountry',
    'AllowsNull') AS ISNULLregioncountry,
  COLUMNPROPERTY(OBJECT_ID('dbo.TestNULLs'), 'COALESCEregioncountry',
    'AllowsNull') AS COALESCEregioncountry;

DROP TABLE IF EXISTS dbo.TestNULLs;
GO

---------------------------------------------------------------------
-- Handling NULLs when combining data from multiple tables
---------------------------------------------------------------------

-- sample data
DROP TABLE IF EXISTS dbo.TableA, dbo.TableB;
GO
CREATE TABLE dbo.TableA
(
  key1 CHAR(1) NOT NULL,
  key2 CHAR(1) NULL,
  A_val VARCHAR(10) NOT NULL,
  CONSTRAINT UNQ_TableA_key1_key2 UNIQUE CLUSTERED (key1, key2)
);

INSERT INTO dbo.TableA(key1, key2, A_val)
  VALUES('w', 'w', 'A w w'),
        ('x', 'y', 'A x y'),
        ('x', NULL, 'A x NULL');

CREATE TABLE dbo.TableB
(
  key1 CHAR(1) NOT NULL,
  key2 CHAR(1) NULL,
  B_val VARCHAR(10) NOT NULL,
  CONSTRAINT UNQ_TableB_key1_key2 UNIQUE CLUSTERED (key1, key2)
);

INSERT INTO dbo.TableB(key1, key2, B_val)
  VALUES('x', 'y', 'B x y'),
        ('x', NULL, 'B x NULL'),
        ('z', 'z', 'B z z');
GO

-- using joins

-- without special NULL handling
SELECT A.A_val, B.B_val
FROM dbo.TableA AS A
  INNER JOIN dbo.TableB AS B
    ON A.key1 = B.key1
    AND A.key2 = B.key2;

-- with special NULL handling, allowing efficient use of indexing
SELECT A.A_val, B.B_val
FROM dbo.TableA AS A
  INNER JOIN dbo.TableB AS B
    ON A.key1 = B.key1
    AND (A.key2 = B.key2 OR A.key2 IS NULL AND B.key2 IS NULL);

-- using COALESCE, prevents ability to rely on index order
SELECT A.A_val, B.B_val
FROM dbo.TableA AS A
  INNER JOIN dbo.TableB AS B
    ON A.key1 = B.key1
    AND COALESCE(A.key2, '<N/A>') = COALESCE(B.key2, '<N/A>');

-- using subqueries, similar handling to joins, only can return values from only one side

-- without special NULL handling
SELECT A.A_val
FROM dbo.TableA AS A
WHERE EXISTS
  ( SELECT * FROM dbo.TableB AS B
    WHERE A.key1 = B.key1
      AND A.key2 = B.key2 );

-- with special NULL handling, allowing efficient use of indexing
SELECT A.A_val
FROM dbo.TableA AS A
WHERE EXISTS
  ( SELECT * FROM dbo.TableB AS B
    WHERE A.key1 = B.key1
      AND (A.key2 = B.key2 OR A.key2 IS NULL AND B.key2 IS NULL) );

-- using COALESCE, prevents ability to rely on index order
SELECT A.A_val
FROM dbo.TableA AS A
WHERE EXISTS
  ( SELECT * FROM dbo.TableB AS B
    WHERE A.key1 = B.key1
    AND COALESCE(A.key2, '<N/A>') = COALESCE(B.key2, '<N/A>') );

-- using set operators, distinctness-based comparison, can't return additional columns
SELECT key1, key2 FROM dbo.TableA
INTERSECT
SELECT key1, key2 FROM dbo.TableB;

-- combining joins, subqueries and set operators
SELECT A.A_val, B.B_val
FROM dbo.TableA AS A
  INNER JOIN dbo.TableB AS B
    ON EXISTS( SELECT A.key1, A.key2
               INTERSECT
               SELECT B.key1, B.key2 );

-- cleanup
DROP TABLE IF EXISTS dbo.TableA, dbo.TableB;

