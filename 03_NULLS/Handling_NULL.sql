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

-------------------------------------------------------------------
