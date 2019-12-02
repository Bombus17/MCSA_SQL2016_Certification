USE [AdventureWorks2017];p
GO

/* CASE expressions 

-- simple CASE expression
-- searched CASE expression

----------------------------------------------*/

/* simple CASE expression
-- returns conditional results

---------------------------------*/
SELECT ProductID
	, [Name]
	, [Availability] = CASE DaysToManufacture
					WHEN '0' THEN 'Immediate'
					WHEN '1' THEN 'Two Business Days'
					WHEN '2' THEN 'Three Business Days'
					WHEN '3' THEN 'Four Business Days'
					ELSE 'Verify Availability'
				  END
FROM Production.Product;

/* Searched CASE expression
-- use comparison values in expression
------------------------------------*/

SELECT ProductID
	, [Name]
	, [Availability] = CASE 
			WHEN DaysToManufacture = '0' THEN 'Immediate'
			WHEN DaysToManufacture >0 AND DaysToManufacture < '4' THEN 'Four Business Days'
			WHEN DaysToManufacture = '4' THEN 'Six Business Days'
			ELSE 'Verify Availability'
		  END
FROM Production.Product;

/* set a range for each order quantity */
SELECT SalesOrderID
	, OrderQty
	,[Range] = CASE WHEN OrderQty BETWEEN 0 AND 9 THEN 'Under 10'
				WHEN OrderQty BETWEEN 10 AND 19 THEN '10-19'
				WHEN OrderQty BETWEEN 20 AND 29 THEN '20-29'
				WHEN OrderQty BETWEEN 30 AND 19 THEN '30-39'
				ElSE '40 and above' 
			END  
FROM Sales.SalesOrderDetail;



