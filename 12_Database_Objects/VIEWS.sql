USE WideWorldImporters
GO

/* VIEWS

-- CREATE VIEW 
-- ALTER VIEW **
-- SCHEMABINDING
-- WITH CHECK OPTION
-- DELETE VIEW
-- Reference view

-- TODO: Finalise this script
----------------------------------------*/



-- view representing ranked products per category by unitprice
DROP VIEW IF EXISTS Sales.RankedProducts;
GO
CREATE VIEW Sales.RankedProducts
AS

SELECT
  ROW_NUMBER() OVER(PARTITION BY categoryid
                    ORDER BY unitprice, productid) AS rownum,
  categoryid, productid, productname, unitprice
FROM Production.Products;
GO

SELECT categoryid, productid, productname, unitprice
FROM Sales.RankedProducts
WHERE rownum <= 2;