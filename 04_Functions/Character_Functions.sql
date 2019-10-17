
USE AdventureWorks2017
GO

/*-----------------------------------------------------

-- SUBSTRING(<expr>,<start position><length>)
-- LEFT(<expr>,<length>)
-- RIGHT(<expr>,<length>)
-- LTRIM, RTRIM
-- UPPER, LOWER, FORMAT
-- LEN
-- CHARINDEX
-- PATINDEX
-- REPLACE
-- REPLICATE
-- STUFF
-- STRING_SPLIT

------------------------------------------------------*/

DECLARE @TestString VARCHAR(50) = 'California'

SELECT SUBSTRING(@TestString, 5, 6) AS [SubString]
	, LEFT(@TestString,4) AS [LEFT]
	, RIGHT(@TestString,6) AS [RIGHT]

/* STRING_SPLIT
-------------------*/

DECLARE @Orders as VARCHAR(MAX) = N'43660, 43661, 43667, 68566, 68656, 75123'

SELECT s.SalesOrderID
, s.OrderDate
, s.AccountNumber
, ROUND(s.TotalDue,2) AS TotalDue
FROM STRING_SPLIT(@Orders, ',') AS K
INNER JOIN Sales.SalesOrderHeader s
	ON s.SalesOrderID = CAST(K.Value AS INT);



