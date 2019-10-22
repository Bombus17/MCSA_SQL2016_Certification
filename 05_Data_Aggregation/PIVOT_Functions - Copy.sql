USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: PIVOT

-- PIVOT and UNPIVOT relational operators change a table-valued expression into another table 
-- PIVOT rotates a table-valued expression by turning the unique values from one column in the expression into multiple columns in the output 
-- PIVOT runs aggregations where they're required on any remaining column values that are wanted in the final output 
-- UNPIVOT carries out the opposite operation to PIVOT by rotating columns of a table-valued expression into column values
-- Any null values in the value column are not considered when computing the aggregation

---------------------------------------------------------------------------------------*/
/* Using this data set 
-- PIVOT the DaysToManufacture (attribute) as a row
-- The Average Cost will be an attribute value in each DaysToManufacture column
---------------------------------------------------------------------------------*/
SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost   
FROM Production.Product  
GROUP BY DaysToManufacture; 

/* PIVOT data 
-- note the NULL value in Column [3]
-- you cannot use ISNULL function in the pivot query
---------------------------------------------------------*/
SELECT 'Avg_Cost' AS Cost_Sorted_By_Production_Days   
		, [0]
		, [1]
		, [2]
		, [3]
		, [4]  
FROM  
	(SELECT DaysToManufacture, StandardCost   
		FROM Production.Product) AS src  
	PIVOT  
	(  
	AVG(StandardCost)  
	FOR DaysToManufacture IN ([0], [1], [2], [3], [4])  
	) AS pvt;  

/* Can be useful when producing report output 
-----------------------------------------------*/
SELECT VendorID
	, [250] AS Emp1
	, [251] AS Emp2
	, [256] AS Emp3
	, [257] AS Emp4
	, [260] AS Emp5  

FROM ( SELECT PurchaseOrderID, EmployeeID, VendorID  
	FROM Purchasing.PurchaseOrderHeader
	) p  
	PIVOT  
	(  COUNT (PurchaseOrderID)  
	FOR EmployeeID IN  ( [250], [251], [256], [257], [260] )  
	) AS pvt  
	ORDER BY pvt.VendorID;  

/* DYNAMIC PIVOT EXAMPLE
------------------------------------------------*/
DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
SET @columns = N'';

SELECT @columns += N'' 
  FROM (SELECT DaysToManufacture, StandardCost   
		FROM Production.Product) AS x;
SET @sql = N'
	SELECT ' + STUFF(@columns, 1, 2, '') + '
	FROM
	(
		SELECT DaysToManufacture, StandardCost   
		FROM Production.Product
	) AS j
	PIVOT
	(
	  AVG(StandardCost) FOR DaysToManufacture IN ('
	  + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '')
	  + ')
	) AS p;';
	PRINT @sql;
	EXEC sp_executesql @sql;

