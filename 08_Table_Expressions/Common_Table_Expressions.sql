USE AdventureWorks2017
GO

/* COMMON TABLE EXPRESSIONS 

-- CTE
-- recursive CTE

*/

WITH sd AS ( SELECT SalesOrderID	
			, ProductID
			FROM Sales.SalesOrderDetail
			)
SELECT sh.SalesOrderID
	, sh.OrderDate
	, ProductID
FROM Sales.SalesOrderHeader sh
INNER JOIN sd
	ON sh.SalesOrderID = sd.SalesOrderID;

-- two products with lowest prices per category
WITH C AS
(
  SELECT ROW_NUMBER() OVER(PARTITION BY ProductSubcategoryID
                    ORDER BY ListPrice, productid) AS rownum
        ,ProductSubcategoryID
		, productid
		, [Name]
		, ListPrice
      FROM Production.Product
)
SELECT ProductSubcategoryID, productid, [Name], ListPrice
FROM C
WHERE rownum <= 2;



-- Recursive CTE
-- management chain leading to given employee
WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname, 0 AS distance
  FROM HR.Employees
  WHERE empid = 9

  UNION ALL

  SELECT M.empid, M.mgrid, M.firstname, M.lastname, S.distance + 1 AS distance
  FROM EmpsCTE AS S
    JOIN HR.Employees AS M
      ON S.mgrid = M.empid
)
SELECT empid, mgrid, firstname, lastname, distance
FROM EmpsCTE;
GO


