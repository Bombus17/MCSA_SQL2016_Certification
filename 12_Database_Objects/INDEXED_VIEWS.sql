USE WideWorldImporters
GO

/* INDEXED VIEWS

-- TODO: Review and test
------------------------------*/



-- recall OrderTotals view
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

-- try to create index clustered index on view (fails)
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid ON Sales.OrderTotals(orderid);
GO

-- add COUNT_BIG
CREATE OR ALTER VIEW Sales.OrderTotals
  WITH SCHEMABINDING
AS

SELECT
  O.orderid, O.custid, O.empid, O.shipperid,  O.orderdate,
  O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val,
  COUNT_BIG(*) AS numorderlines
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY
  O.orderid, O.custid, O.empid, O.shipperid, O.orderdate,
  O.requireddate, O.shippeddate;
GO

-- try to create index (fails)
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid ON Sales.OrderTotals(orderid);
GO

-- remove CAST expression
CREATE OR ALTER VIEW Sales.OrderTotals
  WITH SCHEMABINDING
AS

SELECT
  O.orderid, O.custid, O.empid, O.shipperid,  O.orderdate,
  O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS val,
  COUNT_BIG(*) AS numorderlines
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY
  O.orderid, O.custid, O.empid, O.shipperid, O.orderdate,
  O.requireddate, O.shippeddate;
GO

-- succeeds
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid ON Sales.OrderTotals(orderid);
GO

-- can now create additional nonclustered indexes
CREATE NONCLUSTERED INDEX idx_nc_custid      ON Sales.OrderTotals(custid);
CREATE NONCLUSTERED INDEX idx_nc_empid       ON Sales.OrderTotals(empid);
CREATE NONCLUSTERED INDEX idx_nc_shipperid   ON Sales.OrderTotals(shipperid);
CREATE NONCLUSTERED INDEX idx_nc_orderdate   ON Sales.OrderTotals(orderdate);
CREATE NONCLUSTERED INDEX idx_nc_shippeddate ON Sales.OrderTotals(shippeddate);

-- query view and look at query plan in Figure 3-2
SELECT orderid, custid, empid, shipperid, orderdate,
  requireddate, shippeddate, qty, val, numorderlines
FROM Sales.OrderTotals;

-- if not Enterprise edition use NOEXPAND
SELECT orderid, custid, empid, shipperid, orderdate,
  requireddate, shippeddate, qty, val, numorderlines
FROM Sales.OrderTotals WITH (NOEXPAND);

-- uses index even when querying the underlying tables (see plan in Figure 3-3)
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

-- could create view with different name without CAST, and view with original name with CAST on top of it
CREATE OR ALTER VIEW Sales.VOrderTotals
  WITH SCHEMABINDING
AS

SELECT
  O.orderid, O.custid, O.empid, O.shipperid,  O.orderdate,
  O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS val,
  COUNT_BIG(*) AS numorderlines
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY
  O.orderid, O.custid, O.empid, O.shipperid, O.orderdate,
  O.requireddate, O.shippeddate;
GO

-- create indexes on view
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid ON Sales.VOrderTotals(orderid);
CREATE NONCLUSTERED INDEX idx_nc_custid      ON Sales.VOrderTotals(custid);
CREATE NONCLUSTERED INDEX idx_nc_empid       ON Sales.VOrderTotals(empid);
CREATE NONCLUSTERED INDEX idx_nc_shipperid   ON Sales.VOrderTotals(shipperid);
CREATE NONCLUSTERED INDEX idx_nc_orderdate   ON Sales.VOrderTotals(orderdate);
CREATE NONCLUSTERED INDEX idx_nc_shippeddate ON Sales.VOrderTotals(shippeddate);
GO

-- create view with CAST
CREATE OR ALTER VIEW Sales.OrderTotals
  WITH SCHEMABINDING
AS

SELECT
  orderid, custid, empid, shipperid,  orderdate, requireddate, shippeddate, qty,
  CAST(val AS NUMERIC(12, 2)) AS val
FROM Sales.VOrderTotals;
GO

-- Query view (see plan in Figure 3-4)
SELECT orderid, custid, empid, shipperid,  orderdate,
  requireddate, shippeddate, qty, val
FROM Sales.OrderTotals;
GO

-- Cleanup
DROP VIEW IF EXISTS
  Sales.OrderTotals, Sales.VOrderTotals, Sales.CustLast5OrderDates,
  Sales.CustTop5OrderValues, Sales.OrderValuePcts, Sales.USACusts;
GO