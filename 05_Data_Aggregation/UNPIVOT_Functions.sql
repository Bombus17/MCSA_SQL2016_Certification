USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: UNPIVOT functions

-- UNPIVOT carries out almost the reverse operation of PIVOT, by rotating columns into rows. 
-- UNPIVOT carries out the opposite operation to PIVOT by rotating columns of a table-valued expression into column values


---------------------------------------------------------------------------------------*/
/* using this source data */

DECLARE @tblProducts TABLE ( ProductName NVARCHAR(25)
							, Blue INT
							, Red INT
							, Silver INT
							, Green INT
							, Purple INT
							)
INSERT INTO @tblProducts
VALUES ('Boots', 25, 15, 18, 91, 5)
, ('Bikes', 8, 23, 7, 67, 89)
, ('Helmets', 12, 15, 6, 7, 98)
, ('Clothing', 5, 55, 13, 9, 0)

SELECT * FROM @tblProducts;

SELECT ProductName, Colour, Total
FROM @tblProducts
UNPIVOT
	( Total
	FOR Colour IN ([Blue], [Red], [Silver], [Green], [Purple])
	) AS unpvt;




WITH PivotData AS
(
  SELECT
     [CustomerID]  -- grouping column
    ,[ShipMethodID] -- spreading column
    ,freight    -- aggregation column
  FROM [Sales].[SalesOrderHeader]
)
SELECT *
FROM PivotData
  PIVOT( SUM(freight) FOR [ShipMethodID] IN ([1],[2],[3]) ) AS P;


-- unpivot data
SELECT custid, shipperid, freight
FROM Sales.FreightTotals
  UNPIVOT( freight FOR shipperid IN([1],[2],[3]) ) AS U;
