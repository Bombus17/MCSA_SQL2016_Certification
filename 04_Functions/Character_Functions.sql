
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
-- TRANSLATE
-- STRING_SPLIT

------------------------------------------------------*/

DECLARE @TestString VARCHAR(50) = 'California'

SELECT SUBSTRING(@TestString, 5, 6) AS [SubString]
	, LEFT(@TestString,4) AS [LEFT]
	, RIGHT(@TestString,6) AS [RIGHT]
	, UPPER(@TestString) AS [UPPER]
	, LOWER(@TestString) AS [LOWER];

/* FORMAT */
SELECT FORMAT(123456789, '##-##-#####') AS [FORMAT];

/* DATALENGTH - no of bytes used to represent an expression */
SELECT DATALENGTH(5000000) AS [DataLength];

/* LTRIM - remove leading spaces
	RTRIM - remove ending spaces
	you can nest the functions 
------------------------------------*/

DECLARE @TrimTest VARCHAR(15) = ' Seventeen  '
SELECT LTRIM(@TrimTest) AS [LTRIM]
	, RTRIM(@TrimTest) AS [RTRIM]
	, LTRIM(RTRIM(@TrimTest)) AS [NestedTrim];

/* LEN -- returns the length of a string */

DECLARE @LenTest VARCHAR(30) = 'Mississippi'
SELECT LEN(@LenTest) AS [LEN];


/* REPLACE - replace a given string 
	REPLICATE - repeats a string a given number of times
---------------------------------------*/

DECLARE @RepTest VARCHAR(25) = 'one two three four'
SELECT REPLACE(@RepTest, ' ', '/') AS [REPLACE]
	, REPLICATE(@RepTest, 3) AS [REPLICATE]

/* STUFF - deletes a part of a string and inserts something else in it's place
-----------------------------------------------*/
SELECT STUFF('SQL Coding!', 13, 1, ' is fun!');

/* TRANSLATE - returns string from first arg after characters in 
	the second have been translated into those in the third arg.
---------------------------------------------------------------*/
SELECT TRANSLATE('3*[2+1]/{8-4}', '[]{}', '()()'); 

/* CHARINDEX */
DECLARE  @ProductCode VARCHAR(50)= 'CCCC-DDDDDDD-AAA-BBBBB'

SELECT [Part1] = LEFT(@ProductCode,CHARINDEX('-',@ProductCode) - 1)

       ,[Part2] = SUBSTRING(@ProductCode,CHARINDEX('-',@ProductCode) + 1,
                           CHARINDEX('-',@ProductCode,CHARINDEX('-',
                           @ProductCode) + 1) - (CHARINDEX('-',@ProductCode) + 1))

       ,[Part3] = SUBSTRING(@ProductCode,CHARINDEX('-',
                           @ProductCode,CHARINDEX('-',@ProductCode) + 1) + 1,
                           DATALENGTH(@ProductCode) - CHARINDEX('-',
                           @ProductCode,CHARINDEX('-',@ProductCode) + 1) -
                           CHARINDEX('-',REVERSE(@ProductCode)))

       ,[Part4] = RIGHT(@ProductCode,CHARINDEX('-',REVERSE(@ProductCode)) - 1);

/* PATINDEX( '%pattern%', string ) */
DECLARE @MyValue varchar(10) = 'safety';   
SELECT PATINDEX('%' + @MyValue + '%', DocumentSummary)   AS [PATINDEX]
FROM Production.Document  
WHERE DocumentNode = 0x7B40;

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

/* CHARINDEX and SUBSTRING
-- combine functions to return the characters after the hyphen in the Product Number column
*/

SELECT ProductNumber
	, SUBSTRING(ProductNumber, CHARINDEX('-', ProductNumber)+1, 25) AS ProdNumber
FROM Production.Product;


