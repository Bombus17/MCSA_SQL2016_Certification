USE AdventureWorks2017
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

IF object_id(N'Sales.RankedProducts', 'V') IS NOT NULL DROP VIEW Sales.RankedProducts
GO


CREATE VIEW Sales.RankedProducts
AS

SELECT
  ROW_NUMBER() OVER(PARTITION BY ProductSubcategoryID
                    ORDER BY listPrice, productid) AS rownum,
  ProductSubcategoryID, productid, [Name], ListPrice
FROM Production.Product;
GO

SELECT ProductSubcategoryID, productid, [name], ListPrice
FROM Sales.RankedProducts
WHERE rownum <= 2;

CREATE OR ALTER VIEW Sales.OrderTotals
  WITH SCHEMABINDING
AS

SELECT
  O.orderid, O.custid, O.empid, O.shipperid,  O.orderdate,
  O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY
  O.orderid, O.custid, O.empid, O.shipperid, O.orderdate,
  O.requireddate, O.shippeddate;
GO

-- query view
SELECT orderid, orderdate, custid, empid, val
FROM Sales.OrderTotals;

-- see plan in Figure 3-1 showing access to original tables

-- equivalent query
SELECT
  O.orderid, O.orderdate, O.custid, O.empid,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY
  O.orderid, O.custid, O.empid, O.shipperid, O.orderdate,
  O.requireddate, O.shippeddate;

-- get view definition
PRINT OBJECT_DEFINITION(OBJECT_ID(N'Sales.OrderTotals'));
GO

-- a view can be defined based on a CTE
CREATE OR ALTER VIEW Sales.CustLast5OrderDates
  WITH SCHEMABINDING
AS

WITH C AS
(
  SELECT
    custid, orderdate,
    DENSE_RANK() OVER(PARTITION BY custid ORDER BY orderdate DESC) AS pos
  FROM Sales.Orders
)
SELECT custid, [1], [2], [3], [4], [5]
FROM C
  PIVOT(MAX(orderdate) FOR pos IN ([1], [2], [3], [4], [5])) AS P;
GO

-- query view
SELECT custid, [1], [2], [3], [4], [5]
FROM Sales.CustLast5OrderDates;
GO

-- a view can even be defined based on multiple CTEs
CREATE OR ALTER VIEW Sales.CustTop5OrderValues
  WITH SCHEMABINDING
AS

WITH C1 AS
(
  SELECT
    O.orderid, O.custid,
    CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
         AS NUMERIC(12, 2)) AS val
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON O.orderid = OD.orderid
  GROUP BY
    O.orderid, O.custid
),
C2 AS
(
  SELECT
    custid, val,
    ROW_NUMBER() OVER(PARTITION BY custid ORDER BY val DESC, orderid DESC) AS pos
  FROM C1
)
SELECT custid, [1], [2], [3], [4], [5]
FROM C2
  PIVOT(MAX(val) FOR pos IN ([1], [2], [3], [4], [5])) AS P;
GO

-- query view
SELECT custid, [1], [2], [3], [4], [5]
FROM Sales.CustTop5OrderValues;
GO

-- another example with joining results of aggregates at different levels
CREATE OR ALTER VIEW Sales.OrderValuePcts
  WITH SCHEMABINDING
AS

WITH OrderTotals AS
(
  SELECT
    O.orderid, O.custid,
    SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS val
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON O.orderid = OD.orderid
  GROUP BY
    O.orderid, O.custid
),
GrandTotal AS
(
  SELECT SUM(val) AS grandtotalval FROM OrderTotals
),
CustomerTotals AS
(
  SELECT custid, SUM(val) AS custtotalval
  FROM OrderTotals
  GROUP BY custid
)
SELECT
  O.orderid, O.custid,
  CAST(O.val AS NUMERIC(12, 2)) AS val,
  CAST(O.val / G.grandtotalval * 100.0 AS NUMERIC(5, 2)) AS pctall,
  CAST(O.val / C.custtotalval * 100.0 AS NUMERIC(5, 2)) AS pctcust
FROM OrderTotals AS O
  CROSS JOIN GrandTotal AS G
  INNER JOIN CustomerTotals AS C
    ON O.custid = C.custid;
GO

-- query view
SELECT orderid, custid, val, pctall, pctcust
FROM Sales.OrderValuePcts;
GO

-- alternative
CREATE OR ALTER VIEW Sales.OrderValuePcts
  WITH SCHEMABINDING
AS

WITH OrderTotals AS
(
  SELECT
    O.orderid, O.custid,
    CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS NUMERIC(12, 2)) AS val
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON O.orderid = OD.orderid
  GROUP BY
    O.orderid, O.custid
)
SELECT
  orderid, custid, val,
  CAST(val / SUM(val) OVER() * 100.0 AS NUMERIC(5, 2)) AS pctall,
  CAST(val / SUM(val) OVER(PARTITION BY custid) * 100.0 AS NUMERIC(5, 2)) AS pctcust
FROM OrderTotals;
GO

-- Provide access only to filtered portion
CREATE OR ALTER VIEW Sales.USACusts
  WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

---------------------------------------------------------------------
-- View attributes
---------------------------------------------------------------------

-- SCHEMABINDING

-- without SCHEMABINDING you're allowed to alter table definition
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- alter table
BEGIN TRAN;
  ALTER TABLE Sales.Customers DROP COLUMN address;
ROLLBACK TRAN; -- undo change
GO

-- with SCHEMABINDING
CREATE OR ALTER VIEW Sales.USACusts
  WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- try to alter the underlying table (fails)
ALTER TABLE Sales.Customers DROP COLUMN address;
GO

-- ENCRYPTION 

-- without ENCRYPTION can get object deinition
SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.USACusts'));
GO

-- ENCRYPTION (remember to repeat SCHEMABINDING)
CREATE OR ALTER VIEW Sales.USACusts
  WITH SCHEMABINDING, ENCRYPTION
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- try to get object definition; returns NULL
SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.USACusts'));
GO

---------------------------------------------------------------------
-- Modifying data through views
---------------------------------------------------------------------

-- use following view in modification examples
CREATE OR ALTER VIEW Sales.USACusts
  WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- can modify data through view
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
VALUES(
  N'Customer AAAAA', N'Contact AAAAA', N'Title AAAAA', N'Address AAAAA',
  N'Redmond', N'WA', N'11111', N'USA', N'111-1111111', N'111-1111111');

SELECT custid, companyname, country
FROM Sales.Customers
WHERE custid = SCOPE_IDENTITY();

-- without CHECK option can add/update data that doesn't satisfy WHERE filter

-- WITH CHECK OPTION
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
VALUES(
  N'Customer BBBBB', N'Contact BBBBB', N'Title BBBBB', N'Address BBBBB',
  N'London', NULL, N'22222', N'UK', N'222-2222222', N'222-2222222');

-- can't find customer in view
SELECT custid, companyname, country
FROM Sales.USACusts
WHERE custid = SCOPE_IDENTITY();

-- can find customer in table
SELECT custid, companyname, country
FROM Sales.Customers
WHERE custid = SCOPE_IDENTITY();
GO

-- add CHECK OPTION
CREATE OR ALTER VIEW Sales.USACusts
  WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
WITH CHECK OPTION;
GO

-- try to add row with non-US country (fails)
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
VALUES(
  N'Customer CCCCC', N'Contact CCCCC', N'Title CCCCC', N'Address CCCCC',
  N'London', NULL, N'33333', N'UK', N'333-3333333', N'333-3333333');
GO