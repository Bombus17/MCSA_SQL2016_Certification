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


/* SYSTEM FUNCTIONS 
-- @@ROWCOUNT and ROWCOUNT_BIG
---------------------*/


DECLARE @BusinessEntityID AS INT = 519;

SELECT BusinessEntityID, firstname, lastname
FROM Person.Person
WHERE BusinessEntityID = @BusinessEntityID;

IF @@ROWCOUNT = 0
  PRINT CONCAT('Employee ', CAST(@BusinessEntityID AS VARCHAR(10)), ' was not found.');

-- COMPRESS and DECOMPRESS
/*
INSERT INTO dbo.MyNotes(notes)
  VALUES(COMPRESS(@notes));

SELECT keycol
  CAST(DECOMPRESS(notes) AS NVARCHAR(MAX)) AS notes
FROM dbo.MyNotes;
*/

-- CONTEXT_INFO and SESSION_CONTEXT
DECLARE @mycontextinfo AS VARBINARY(128) = CAST('us_english' AS VARBINARY(128));
SET CONTEXT_INFO @mycontextinfo;
GO

SELECT CAST(CONTEXT_INFO() AS VARCHAR(128)) AS mycontextinfo;

EXEC sys.sp_set_session_context 
  @key = N'language', @value = 'us_english', @read_only = 1; 

SELECT SESSION_CONTEXT(N'language') AS [language];

-- GUID and identity functions
SELECT NEWID() AS myguid;
