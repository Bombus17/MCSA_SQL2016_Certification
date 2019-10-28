use WideWorldImporters
go

/* ARITHMETIC OPERATORS 
-- PRECEDENCE
-----------------------------*/

SELECT 2 + 3 * 2 + 10 / 2;

SELECT 2 + (3 * 2) + (10 / 2);

SELECT ((2 + 3) * 2 + 10) / 2;

SELECT 9 / 2;
GO

-- explicit conversion
DECLARE @p1 AS INT = 9, @p2 AS INT = 2;
SELECT CAST(@p1 AS NUMERIC(12, 2)) / CAST(@p2 AS NUMERIC(12, 2));
GO

DECLARE @p1 AS INT = 9, @p2 AS INT = 2;
SELECT 1.0 * @p1 / @p2;
GO


---------------------------------------------------------------------
-- Example involving arithmetic operators and aggregate functions
---------------------------------------------------------------------

-- median
DECLARE @cnt AS INT = (SELECT COUNT(*) FROM Sales.OrderLines);

SELECT AVG(1.0 * [Quantity]) AS median
FROM ( SELECT [Quantity]
       FROM Sales.OrderLines
       ORDER BY [Quantity]
       OFFSET (@cnt - 1) / 2 ROWS FETCH NEXT 2 - @cnt % 2 ROWS ONLY ) AS D;
GO
