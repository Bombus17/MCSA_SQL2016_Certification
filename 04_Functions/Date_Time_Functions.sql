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

/* use DATEDIFF to determine the number of days between dates */

SELECT SalesOrderID, OrderDate, ShipDate
	, DATEDIFF(d, OrderDate, ShipDate) AS NoOfDays
FROM Sales.SalesOrderHeader;

/* retrieve only the date from a datetime field */

SELECT CONVERT(VARCHAR,OrderDate,1) AS OrderDate
	, CONVERT(VARCHAR, ShipDate,1) AS ShipDate
FROM Sales.SalesOrderHeader;

/* Use DATEADD to determine future dates 
-- use negative values to get dates prior
------------------------------------------------*/
SELECT SalesOrderID
	, OrderDate
	, DATEADD(M, 4, OrderDate) AS PlusFourMonths
FROM Sales.SalesOrderHeader;

/* retrieve date parts */
SELECT SalesOrderID
	, OrderDate
	, YEAR(OrderDate) AS OrderYear
	, MONTH(OrderDate) AS OrderMN_Month
	, DATEPART(m, OrderDate) AS OrderMN_Datepart
	, DATENAME(m, OrderDate) AS OrderMonthName
FROM Sales.SalesOrderHeader;





