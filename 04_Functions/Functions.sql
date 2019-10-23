USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Functions

-- Using T-SQL functions
-- system functions
-- standard vs non-standard
-- function determinism


---------------------------------------------------------------------------------------*/

/* FUNCTION DETERMINISM 

-- deterministic: returns the same result given the same set of input values
-- non deterministic: does not return the same result each time

-- Three Categories
-- Always deterministic
-- Deterministic when invoked in a certain way
-- Non deterministic

---------------------------------------------------------*/

/* Always Deterministic 

-- not an exhaustive list, there are many more
-----------------------------*/

DECLARE @X VARCHAR(3) = NULL
	, @Y VARCHAR(5) = '12456'
	, @Z VARCHAR(6) = 'Hello'
	, @Num INT = -1765
	, @SQ INT = 625

SELECT COALESCE(@X, @Y, @Z) AS [COALESCE]
	, ISNULL(@X, 'NaN') AS [ISNULL]
	, ABS(@Num) AS [ABS]
	, SQRT(@SQ) AS [SQRT];

/* Sometimes deterministic 

-- depends on how they're used
-- the example below varies based on language settings
----------------------------------------*/

DECLARE @Dt DATETIME2 = GETDATE()
DECLARE @Rand INT = 1759

SELECT CAST(@Dt AS DATE) AS [Date] ;
SELECT RAND(@Rand) AS [RAND];
SELECT RAND();

/* Non Deterministic

-- invoked once per query

Note: the use of a non-deterministic function on a computed column
-- prevents the ability to create an index on the column
-- Also, when used on a view, will prevent the ability to create a clustered index on the view

----------------------------------------------------*/

SELECT BusinessEntityID, SYSDATETIME() AS Dt_Now, RAND() AS [RAND], NEWID() AS newGUID
FROM HumanResources.Employee;

/* check if a funtion is deterministic */


