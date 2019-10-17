USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: handling NULLs in T-SQL 

-- NULLs in predicates
-- NULL as placeholders (see Using_Joins.sql)
-- ISNULL
-- NULLIF
-- COALESCE
-- CONCAT and NULL
-- Date Time and NULL
-- How NULLs are handled in COUNT(*)
-- sorting data and NULL
-- comparing NULL
-- using NULL in aggregate functions
-- using NULL in PIVOT
-- using NULL in UNPIVOT
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

--------------------------------------*/