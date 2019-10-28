USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: insert data

-- insert into values
-- insert select
-- insert exec
-- insert with variables
-- insert with table variables
-- INSERT with OUTPUT

---------------------------------------------------------------------------------------*/

-- create table Sales.MyOrders
USE TSQLV4;
DROP TABLE IF EXISTS Sales.MyOrders;
GO

CREATE TABLE Sales.MyOrders
(
  orderid INT NOT NULL IDENTITY(1, 1)
    CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
  custid  INT NOT NULL,
  empid   INT NOT NULL,
  orderdate DATE NOT NULL
    CONSTRAINT DFT_MyOrders_orderdate DEFAULT (CAST(SYSDATETIME() AS DATE)),
  shipcountry NVARCHAR(15) NOT NULL,
  freight MONEY NOT NULL
);

---------------------------------------------------------------------
-- INSERT VALUES
---------------------------------------------------------------------

-- single row
INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight)
  VALUES(2, 19, '20170620', N'USA', 30.00);

-- relying on defaults
INSERT INTO Sales.MyOrders(custid, empid, shipcountry, freight)
  VALUES(3, 11, N'USA', 10.00);

INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight)
  VALUES(3, 17, DEFAULT, N'USA', 30.00);

-- multiple rows
INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight) VALUES
  (2, 11, '20170620', N'USA', 50.00),
  (5, 13, '20170620', N'USA', 40.00),
  (7, 17, '20170620', N'USA', 45.00);

-- query the table
SELECT * FROM Sales.MyOrders;

---------------------------------------------------------------------
-- INSERT SELECT
---------------------------------------------------------------------

SET IDENTITY_INSERT Sales.MyOrders ON;

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate, shipcountry, freight)
  SELECT orderid, custid, empid, orderdate, shipcountry, freight
  FROM Sales.Orders
  WHERE shipcountry = N'Norway';

SET IDENTITY_INSERT Sales.MyOrders OFF;

-- query the table
SELECT * FROM Sales.MyOrders;

---------------------------------------------------------------------
-- INSERT EXEC
---------------------------------------------------------------------

-- create procedure
DROP PROC IF EXISTS Sales.OrdersForCountry;
GO

CREATE PROC Sales.OrdersForCountry
  @country AS NVARCHAR(15)
AS

SELECT orderid, custid, empid, orderdate, shipcountry, freight
FROM Sales.Orders
WHERE shipcountry = @country;
GO

-- insert the result of the procedure
SET IDENTITY_INSERT Sales.MyOrders ON;

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate, shipcountry, freight)
  EXEC Sales.OrdersForCountry
    @country = N'Portugal';

SET IDENTITY_INSERT Sales.MyOrders OFF;

-- query the table
SELECT * FROM Sales.MyOrders;

---------------------------------------------------------------------
-- SELECT INTO
---------------------------------------------------------------------

-- simple SELECT INTO
DROP TABLE IF EXISTS Sales.MyOrders;

SELECT orderid, custid, orderdate, shipcountry, freight
INTO Sales.MyOrders
FROM Sales.Orders
WHERE shipcountry = N'Norway';

-- remove identity property, make column NULLable, change column's type
DROP TABLE IF EXISTS Sales.MyOrders;

SELECT 
  ISNULL(orderid + 0, -1) AS orderid, -- get rid of identity property
                                      -- make column NOT NULL
  ISNULL(custid, -1) AS custid, -- make column NOT NULL
  empid, 
  ISNULL(CAST(orderdate AS DATE), '19000101') AS orderdate,
  shipcountry, freight
INTO Sales.MyOrders
FROM Sales.Orders
WHERE shipcountry = N'Norway';

-- create constraints
ALTER TABLE Sales.MyOrders
  ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

-- query the table
SELECT * FROM Sales.MyOrders;

-- cleanup
DROP TABLE IF EXISTS Sales.MyOrders;

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


---------------------------------------------------------------------
-- INSERT with OUTPUT
---------------------------------------------------------------------

INSERT INTO Sales.MyOrders(custid, empid, orderdate)
  OUTPUT
    inserted.orderid, inserted.custid, inserted.empid, inserted.orderdate
  SELECT custid, empid, orderdate
  FROM Sales.Orders
  WHERE shipcountry = N'Norway';

-- could use INTO
/*
INSERT INTO Sales.MyOrders(custid, empid, orderdate)
  OUTPUT
    inserted.orderid, inserted.custid, inserted.empid, inserted.orderdate
    INTO SomeTable(orderid, custid, empid, orderdate)
  SELECT custid, empid, orderdate
  FROM Sales.Orders
  WHERE shipcountry = N'Norway';
*/