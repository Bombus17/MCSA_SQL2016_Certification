USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: UPDATE data


---------------------------------------------------------------------------------------*/


---------------------------------------------------------------------
-- UPDATE based on join
---------------------------------------------------------------------

-- show state before update
SELECT OD.*
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.MyOrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE C.country = N'Norway';

-- update
UPDATE OD
  SET OD.discount += 0.05
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.MyOrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE C.country = N'Norway';

-- state after update
SELECT OD.*
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.MyOrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE C.country = N'Norway';

-- cleanup
UPDATE OD
  SET OD.discount -= 0.05
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.MyOrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE C.country = N'Norway';

---------------------------------------------------------------------
-- Nondeterministic UPDATE
---------------------------------------------------------------------

-- show current state
SELECT C.custid, C.postalcode, O.shippostalcode
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid
ORDER BY C.custid;

-- update
UPDATE C
  SET C.postalcode = O.shippostalcode
FROM Sales.MyCustomers AS C
  INNER JOIN Sales.MyOrders AS O
    ON C.custid = O.custid;

-- show state after update
SELECT custid, postalcode
FROM Sales.MyCustomers
ORDER BY custid;

-- update to the postal code associated with the first order
UPDATE C
  SET C.postalcode = A.shippostalcode
FROM Sales.MyCustomers AS C
  CROSS APPLY (SELECT TOP (1) O.shippostalcode
               FROM Sales.MyOrders AS O
               WHERE O.custid = C.custid
               ORDER BY orderdate, orderid) AS A;

-- show state after update
SELECT custid, postalcode
FROM Sales.MyCustomers
ORDER BY custid;

---------------------------------------------------------------------
-- UPDATE based on a variable
---------------------------------------------------------------------

-- current state of the data
SELECT *
FROM Sales.MyOrderDetails
WHERE orderid = 10250
  AND productid = 51;
GO

DECLARE @newdiscount AS NUMERIC(4, 3) = NULL;

UPDATE Sales.MyOrderDetails
  SET @newdiscount = discount += 0.05
WHERE orderid = 10250
  AND productid = 51;

SELECT @newdiscount;
GO

-- cleanup
UPDATE Sales.MyOrderDetails
  SET discount -= 0.05
WHERE orderid = 10250
  AND productid = 51;

---------------------------------------------------------------------
-- UPDATE all-at-once
---------------------------------------------------------------------

-- create table T1
DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  col1 INT NOT NULL, 
  col2 INT NOT NULL
);

INSERT INTO dbo.T1(keycol, col1, col2) VALUES(1, 100, 0);
GO

-- what's the value of col2 after the following UPDATE
DECLARE @add AS INT = 10;

UPDATE dbo.T1
  SET col1 += @add, col2 = col1
WHERE keycol = 1;

SELECT * FROM dbo.T1;

-- cleanup
DROP TABLE IF EXISTS dbo.T1;


---------------------------------------------------------------------
-- Updating data
---------------------------------------------------------------------

-- sample data for UPDATE and DELETE sections
DROP TABLE IF EXISTS Sales.MyOrderDetails, Sales.MyOrders, Sales.MyCustomers;

SELECT * INTO Sales.MyCustomers FROM Sales.Customers;
ALTER TABLE Sales.MyCustomers
  ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(custid);

SELECT * INTO Sales.MyOrders FROM Sales.Orders;
ALTER TABLE Sales.MyOrders
  ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

SELECT * INTO Sales.MyOrderDetails FROM Sales.OrderDetails;
ALTER TABLE Sales.MyOrderDetails
  ADD CONSTRAINT PK_MyOrderDetails PRIMARY KEY(orderid, productid);

---------------------------------------------------------------------
-- UPDATE statement
---------------------------------------------------------------------

-- add 5 percent discount to order lines of order 10251

-- first show current state
SELECT *
FROM Sales.MyOrderDetails
WHERE orderid = 10251;

-- update
UPDATE Sales.MyOrderDetails
  SET discount += 0.05
WHERE orderid = 10251;

-- show state after update
SELECT *
FROM Sales.MyOrderDetails
WHERE orderid = 10251;

-- cleanup
UPDATE Sales.MyOrderDetails
  SET discount -= 0.05
WHERE orderid = 10251;

