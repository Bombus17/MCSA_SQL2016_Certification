USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Functions and Dates

-- Date and Time functions
-- DATE from parts: DATEFROMPARTS(), DATETIME2FROMPARTS(), DATETIMEFROMPARTS(), DATETIMEOFFSETFROMPARTS()
				SMALLDATETIMEFROMPARTS(), TIMEFROMPARTS()
-- DATEDIFF: DATEDIFF(), DATEDIFF_BIG()
-- DATEADD: DATEADD(), EOMONTH(), SWITCHOFFSET(), TODATETIMEOFFSET()
-- DATENAME FUNCTIONS
-- OFFSET related functions
-- TIME ZONE FUNCTIONS
-- TIME ZONE WITH OFFSET
-- Higher precsion functions: SYSDATETIME(), SYSDATETIMEOFFSET(), SYSUTCDATETIME()
-- Lower precision functions: CURRENT_TIMESTAMP(), GETDATE(), GETUTCDATE()
-- Validate dates: ISDATE()
-- Ranges
-- Date formats: see https://www.sqlshack.com/sql-convert-date-functions-and-formats/


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

/* use DATEDIFF to determine the number of days between dates 
---------------------------------------------------------------*/

SELECT SalesOrderID, OrderDate, ShipDate
	, DATEDIFF(d, OrderDate, ShipDate) AS NoOfDays
FROM Sales.SalesOrderHeader;

/* retrieve only the date from a datetime field 
-------------------------------------------------*/

SELECT CONVERT(VARCHAR,OrderDate,1) AS OrderDate
	, CONVERT(VARCHAR, ShipDate,1) AS ShipDate
FROM Sales.SalesOrderHeader;

SELECT 
	DATEDIFF(YEAR, GETDATE(), GETDATE()+1) AS InYear,
    DATEDIFF(QUARTER , GETDATE(), GETDATE()+1) AS InQuarter,
	DATEDIFF(MONTH, GETDATE(), GETDATE()+1) AS InMonth,
	DATEDIFF(DAYOFYEAR , GETDATE(), GETDATE()+1) AS InDayOfYear,
	DATEDIFF(WEEK  , GETDATE(), GETDATE()+1) AS InWeek,
    DATEDIFF(DAY, GETDATE(), GETDATE()+1) AS InDays,
	DATEDIFF(HOUR , GETDATE(), GETDATE()+1) AS InHour,
	DATEDIFF(MINUTE, GETDATE(), GETDATE()+1) AS InMinute,
	DATEDIFF(SECOND, GETDATE(), GETDATE()+1) AS InSec,
	DATEDIFF(MILLISECOND, GETDATE(), GETDATE()+1 ) AS DiffInMilSec

	/* DATENAME FUNCTIONS

	-----------------------------------------------*/

SELECT DATENAME(YEAR, GETDATE())        AS 'Year';        
SELECT DATENAME(QUARTER, GETDATE())     AS 'Quarter';     
SELECT DATENAME(MONTH, GETDATE())       AS 'Month';       
SELECT DATENAME(DAYOFYEAR, GETDATE())   AS 'DayOfYear';   
SELECT DATENAME(DAY, GETDATE())         AS 'Day';         
SELECT DATENAME(WEEK, GETDATE())        AS 'Week';        
SELECT DATENAME(WEEKDAY, GETDATE())     AS 'WeekDay';     
SELECT DATENAME(HOUR, GETDATE())        AS 'Hour';        
SELECT DATENAME(MINUTE, GETDATE())      AS 'Minute';      
SELECT DATENAME(SECOND, GETDATE())      AS 'Second';      
SELECT DATENAME(MILLISECOND, GETDATE()) AS 'MilliSecond'; 
SELECT DATENAME(MICROSECOND, GETDATE()) AS 'MicroSecond'; 
SELECT DATENAME(NANOSECOND, GETDATE())  AS 'NanoSecond';  
SELECT DATENAME(ISO_WEEK, GETDATE())    AS 'Week';  

/* Use DATEADD to determine future dates 
-- use negative values to get dates prior

DATEADD - returns datepart with added interval as a datetime
EOMONTH – returns last day of month of offset as type of start_date 
SWITCHOFFSET - returns date and time offset and time zone offset
TODATETIMEOFFSET - returns date and time with time zone offset
-- modify date and time
------------------------------------------------*/
SELECT DATEADD(DAY,1,GETDATE())        AS 'DatePlus1';          -- returns data type of the date argument
SELECT EOMONTH(GETDATE(),1)            AS 'LastDayOfNextMonth'; -- returns start_date argument or date
SELECT SWITCHOFFSET(GETDATE(), -6)     AS 'NowMinus6';          -- returns datetimeoffset
SELECT TODATETIMEOFFSET(GETDATE(), -2) AS 'Offset';             -- returns datetimeoffset

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

/* DATE FROM PARTS 

DATEFROMPARTS – returns a date from the date specified
DATETIME2FROMPARTS – returns a datetime2 from part specified
DATETIMEFROMPARTS – returns a datetime from part specified
DATETIMEOFFSETFROMPARTS - returns a datetimeoffset from part specified 
SMALLDATETIMEFROMPARTS - returns a smalldatetime from part specified 
TIMEFROMPARTS - returns a time from part specified
------------------------------------------------------------*/

SELECT DATEFROMPARTS(2019,1,1)                         AS 'Date';          -- returns date
SELECT DATETIME2FROMPARTS(2019,1,1,6,0,0,0,1)          AS 'DateTime2';     -- returns datetime2
SELECT DATETIMEFROMPARTS(2019,1,1,6,0,0,0)             AS 'DateTime';      -- returns datetime
SELECT DATETIMEOFFSETFROMPARTS(2019,1,1,6,0,0,0,0,0,0) AS 'Offset';        -- returns datetimeoffset
SELECT SMALLDATETIMEFROMPARTS(2019,1,1,6,0)            AS 'SmallDateTime'; -- returns smalldatetime
SELECT TIMEFROMPARTS(6,0,0,0,0)                        AS 'Time';          -- returns time

/*
-- Offset related functions
-----------------------------*/

-- SWITCHOFFSET
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00') AS [SWTCHOFFSET];
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-08:00') AS [SWTCHOFFSET];

-- example with both functions
SELECT 
  SWITCHOFFSET('20190212 14:00:00.0000000 -05:00', '-08:00') AS [SWITCHOFFSET],
  TODATETIMEOFFSET('20190212 14:00:00.0000000', '-08:00') AS [TODATETIMEOFFSET];

-- AT TIME ZONE when similar to SWITCHOFFSET
SELECT SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time';

-- AT TIME ZONE when similar to TODATETIMEOFFSET
DECLARE @dat AS DATETIME2 = '20190212 14:00:00.0000000';
SELECT @dat AT TIME ZONE 'Pacific Standard Time';

/*  time zones
------------------------------------------*/
SELECT * FROM sys.time_zone_info;

DECLARE @CurrentTimeZone NVARCHAR(100) 
EXEC master.dbo.xp_regread 
    N'HKEY_LOCAL_MACHINE',
    N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
    N'TimeZoneKeyName',
    @CurrentTimeZone OUTPUT

SELECT @CurrentTimeZone AS LocalTimeZone;

/* TIME ZONE WITH OFFSET 
------------------------------------*/

DECLARE @JordanCurrentDateTime datetime 
DECLARE @JordanOffset datetimeoffset
DECLARE @USADateTime datetime
DECLARE @USTimeZone nvarchar(10)
 
SET @JordanCurrentDateTime=  GETDATE()
SELECT @JordanOffset = @JordanCurrentDateTime AT TIME ZONE 'Jordan Standard Time'
SELECT @JordanOffset AS JordanTimeWithOffset
 
DECLARE @UTCOffset datetimeoffset
SELECT @UTCOffset = SWITCHOFFSET(@JordanOffset, '+00:00')
SELECT @UTCOffset AS JordanTimeWithUTCOffset
SELECT @USTimeZone= DATENAME(TZ, @UTCOffset  AT TIME ZONE 'US Eastern Standard Time')
SELECT @USTimeZone AS USOffset
SELECT @USADateTime = SWITCHOFFSET(@UTCOffset, @USTimeZone)
SELECT @USADateTime AS DateTimeInUSA
 

-- two conversions
DECLARE @dtt AS DATETIME2 = '20190212 14:00:00.0000000'; -- stored as UTC
SELECT @dtt AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'; -- switched to Pacific Standard Time

/* HIGHER PRECISION TIME FUNCTIONS 

SQL Server High Precision Date and Time Functions have a scale of 7 and are:

	SYSDATETIME – returns the date and time of the machine the SQL Server is running on
	SYSDATETIMEOFFSET – returns the date and time of the machine the SQL Server is running on plus the offset from UTC
	SYSUTCDATETIME - returns the date and time of the machine the SQL Server is running on as UTC
-------------------------------------------------------------------------------------------------*/
SELECT SYSDATETIME()       AS [SYS_dt_time]        -- return datetime2(7)       
SELECT SYSDATETIMEOFFSET() AS [SYS_DT_TIME_OFFST]; -- datetimeoffset(7)
SELECT SYSUTCDATETIME()    AS [SYS_UTC_DT_TIME];   -- returns datetime2(7)

/* LESSER PRECISION DATA AND TIME FUNCTIONS
SQL Server Lesser Precision Data and Time Functions have a scale of 3 and are:
	CURRENT_TIMESTAMP - returns the date and time of the machine the SQL Server is running on
	GETDATE() - returns the date and time of the machine the SQL Server is running on
	GETUTCDATE() - returns the date and time of the machine the SQL Server is running on as UTC
--------------------------------------------------------------------------------------*/
-- lesser precision functions - returns datetime
SELECT CURRENT_TIMESTAMP AS [CRNT_DT_STAMP]; -- note: no parentheses   
SELECT GETDATE()         AS [GETDT];    
SELECT GETUTCDATE()      AS [GET_UTC_DT]; 

-- validate date and time - returns int
SELECT ISDATE(GETDATE()) AS 'IsDate'; 
SELECT ISDATE(NULL) AS 'IsDate';

