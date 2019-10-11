USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: Filtering date and time data

-- use correct form of literals
-- use appropriate ranges 
-- date formats are important (e.g. UK vs US date format)
-- consider language neutral approach (data type dependent)
-- can also explicitly convert the string to the target type (performance considerations)

---------------------------------------------------------------------------------------*/
/* Get all UK Sales 

-------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'

/* Get all UK Sales for a specified date
-- this will not work due to a data type conversion error
-------------------------------------------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'
AND so.OrderDate = '30/06/2014';


/* Get all UK Sales for a specified date
-- use language neutral formatting
-- BUT this is dependent on data types
-- this form is language dependent for DATETIME and SMALLDATETIME
--
-------------------------------------------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'
AND so.OrderDate = '20140630';

/* Get all UK Sales for a specified date
-- could explicitly convert the date to the required format
-- there are performance considerations when applying formatting
to a WHERE clause
-- NOTE: American date format
-------------------------------------------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'
AND so.OrderDate = CONVERT(DATE,'06/30/2014',101);

/* Get all UK Sales for May 2014
-- take care with data types
-- rounding by milliseconds (depending on datatype) can cause dates to be excluded from ranges
-- also datetime data can have midnight stored as time so extra dates may be included. 
------------------------------------------------------------------------------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'
AND so.OrderDate BETWEEN '20140401' AND '20140430';

/* Get all UK Sales for a 2014
-- take care with data types
-- rounding by milliseconds (depending on datatype) can cause dates to be excluded from ranges
-- also datetime data can have midnight stored as time so extra dates may be included. 

-- recommended method is to use operators 
--------------------------------------------------------------------------------------*/
SELECT so.*
FROM [Sales].[SalesOrderHeader] so
LEFT JOIN[Person].[StateProvince] t
ON so.TerritoryID = t.TerritoryID
WHERE t.Name = N'England'
AND so.OrderDate >= '20140401' AND so.OrderDate < '20140430';

