USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: APPLY OPERATOR

-- APPLY
-- CROSS APPLY
-- OUTER APPLY
-- logical processing aspects
-- optimisation  when using apply operators

TODO: finish this script
---------------------------------------------------------------------------------------*/

/*  -- CROSS APPLY 
-- right table expression applied to each row from left input
-- if right table expression returns an empty set for the left row
-- the left row isn't returned (see also OUTER APPLY)


OUTER APPLY 
-- extends cross apply
-- includes rows from the left table that return an empty set
-- NULLs as placeholders
-- preserves LEFT side
--APPLY operator is required when you have to use a table-valued function in the query, 
-- but it can also be used with inline SELECT statements

*/