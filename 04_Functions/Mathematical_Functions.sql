USE AdventureWorks2017
GO

/* MATHEMATICAL FUNCTIONS

-- be aware of precedence

-- there are many, this list is not exhaustive
-- see MS documentation
-- ROUND (<expr>, length, [, function])
-- SQRT
-- FLOOR
-- CEILING
-- EXP
-- POWER
-- LOG10
-- SQUARE
----------------------------------*/

DECLARE @TestValue FLOAT = 765.52

/* ROUND
-- returns a rounded numeric expression (with negative length)
-- can be used to estimate
------------------------------ */
SELECT ROUND(@TestValue, -1) AS [Rnd_1]
, ROUND(CAST (@TestValue AS decimal (6,2)),-3) AS [4digits]; -- round to 4 digits

SELECT TOP 10 SalesOrderID
	, ROUND(SubTotal,2) AS SubTot
	, ROUND(SubTotal,0) AS SubTotzero
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID DESC;


/* FLOOR / CEILING */

SELECT @TestValue AS [TestValue]
	, FLOOR(@TestValue) AS [Flr]
	, CEILING(@TestValue) AS [Ceil]


/* SQRT / SQUARE
	-- SQRT square root of specified float value 
	-- SQUARE 
-----------------------------------*/
DECLARE @SQTest FLOAT = 25

SELECT SQRT(@SQTest) AS [SquareRoot]
, SQUARE(@SQTest) AS [Square]

/* EXP / POWER 
-- exponential of given value
-- value of expression raised to given power
--------------------------*/
SELECT POWER(9,4)
	, EXP( LOG(20))
	, LOG( EXP(20)) 
	
/* generate random numbers */

SELECT CAST(RAND() * 10 AS INT) + 1;

