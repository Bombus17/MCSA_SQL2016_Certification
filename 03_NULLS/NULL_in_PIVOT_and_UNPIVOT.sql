USE WideWorldImporters
GO

/* KEEPING NULLS WHEN UNPIVOTING OR PIVOTING DATA 


-- see PIVOT and UNPIVOT scripts for test data
-------------------------------------------*/

DROP TABLE IF EXISTS Sales.FreightTotals;
GO

WITH PivotData AS
(
  SELECT
    custid,    -- grouping column
    shipperid, -- spreading column
    freight    -- aggregation column
  FROM Sales.Orders
)
SELECT *
INTO Sales.FreightTotals
FROM PivotData
  PIVOT( SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;

SELECT * FROM Sales.FreightTotals;

-- unpivot data
SELECT custid, shipperid, freight
FROM Sales.FreightTotals
  UNPIVOT( freight FOR shipperid IN([1],[2],[3]) ) AS U;

-- keep NULLs
WITH C AS
(
  SELECT custid,
    ISNULL([1], 0.00) AS [1],
    ISNULL([2], 0.00) AS [2],
    ISNULL([3], 0.00) AS [3]
  FROM Sales.FreightTotals
)
SELECT custid, shipperid, NULLIF(freight, 0.00) AS freight
FROM C
  UNPIVOT( freight FOR shipperid IN([1],[2],[3]) ) AS U;

-- cleanup
DROP TABLE IF EXISTS Sales.FreightTotals;