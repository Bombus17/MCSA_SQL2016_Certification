USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Functions and Dates

-- Date functions
-- Time functions
-- Formats
-- Date diffs
-- Offset
-- Precision
-- Ranges

TODO: FINISH THIS SCRIPT

Note: List not exhaustive
-----------------------------------------------------*/
-- Date and Time functions
SELECT CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP] -- system date and time w/o time zone
	, GETUTCDATE() AS [GETUTCDATE] -- Returns the current database system timestamp as a datetime value
	, GETDATE() AS [GETDATE] -- time on the operating system on which server is running
	, SYSDATETIME() AS [SYSDATETIME] -- more precision than getdate()
	, SYSUTCDATETIME() AS [SYSUTCDATETIME] -- in UTC time
	, SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET]; -- with Time Zone

-- Date and Time parts
DECLARE @Dt DATETIME = GETDATE();

SELECT DATEPART(dd, @Dt) AS [Day] -- as integer
	, DATEPART(mm, @Dt) AS [Month] -- month number
	, DATEPART(yy, @Dt) AS [Year] -- integer
	, DATENAME(dd, @Dt) AS [Day]
	, DATENAME(MM, @Dt) AS [Mnth] -- Month name
	, DATEADD(dd,14,@Dt) AS [14daysFromNow]
	, EOMONTH(@Dt, 1) AS [LastDayOfNextMonth]
	, EOMONTH(@Dt, 0) AS [LastDayOfThisMonth]

