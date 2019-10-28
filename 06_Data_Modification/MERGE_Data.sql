USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: MERGE data

-- update where exists, insert where does not exist
-- update where exists but only if the data is different
-- delete when exists in target but not in source
-- MERGE with OUTPUT
---------------------------------------------------------------------------------------*/


---------------------------------------------------------------------
-- Using the MERGE statement
---------------------------------------------------------------------

-- create table and sequence if they don't already exist
DROP TABLE IF EXISTS Sales.MyOrders;
DROP SEQUENCE IF EXISTS Sales.SeqOrderIDs;

CREATE SEQUENCE Sales.SeqOrderIDs AS INT
  MINVALUE 1
  CACHE 10000;

CREATE TABLE Sales.MyOrders
(
  orderid INT NOT NULL
    CONSTRAINT PK_MyOrders_orderid PRIMARY KEY
    CONSTRAINT DFT_MyOrders_orderid
      DEFAULT(NEXT VALUE FOR Sales.SeqOrderIDs),
  custid  INT NOT NULL
    CONSTRAINT CHK_MyOrders_custid CHECK(custid > 0),
  empid   INT NOT NULL
    CONSTRAINT CHK_MyOrders_empid CHECK(empid > 0),
  orderdate DATE NOT NULL
);
GO

-- update where exists, insert where not exists
DECLARE
  @orderid   AS INT  = 1, @custid    AS INT  = 1,
  @empid     AS INT  = 2, @orderdate AS DATE = '20170212';

MERGE INTO Sales.MyOrders WITH (SERIALIZABLE) AS TGT
USING (VALUES(@orderid, @custid, @empid, @orderdate))
       AS SRC( orderid,  custid,  empid,  orderdate)
  ON SRC.orderid = TGT.orderid -- merge predicate
WHEN MATCHED THEN
  UPDATE
    SET TGT.custid    = SRC.custid,
        TGT.empid     = SRC.empid,
        TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN
  INSERT VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate);
GO

-- update where exists (only if different), insert where not exists
DECLARE
  @orderid   AS INT  = 1, @custid    AS INT  = 1,
  @empid     AS INT  = 2, @orderdate AS DATE = '20170212';

MERGE INTO Sales.MyOrders WITH (SERIALIZABLE) AS TGT
USING (VALUES(@orderid, @custid, @empid, @orderdate))
       AS SRC( orderid,  custid,  empid,  orderdate)
  ON SRC.orderid = TGT.orderid
WHEN MATCHED AND (   TGT.custid    <> SRC.custid
                  OR TGT.empid     <> SRC.empid
                  OR TGT.orderdate <> SRC.orderdate) THEN
  UPDATE
    SET TGT.custid    = SRC.custid,
        TGT.empid     = SRC.empid,
        TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN
  INSERT VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate);
GO

-- Alternative: WHEN MATCHED AND EXISTS( SELECT SRC.* EXCEPT SELECT TGT.* ) THEN UPDATE

-- table as source
DECLARE @Orders AS TABLE
(
  orderid   INT  NOT NULL PRIMARY KEY,
  custid    INT  NOT NULL,
  empid     INT  NOT NULL,
  orderdate DATE NOT NULL
);

INSERT INTO @Orders(orderid, custid, empid, orderdate)
  VALUES (2, 1, 3, '20170212'),
         (3, 2, 2, '20170212'),
         (4, 3, 5, '20170212');

-- update where exists (only if different), insert where not exists,
-- delete when exists in target but not in source
MERGE INTO Sales.MyOrders AS TGT
USING @Orders AS SRC
  ON SRC.orderid = TGT.orderid
WHEN MATCHED AND EXISTS( SELECT SRC.* EXCEPT SELECT TGT.* ) THEN
  UPDATE
    SET TGT.custid    = SRC.custid,
        TGT.empid     = SRC.empid,
        TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN
  INSERT VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

-- query table
SELECT * FROM Sales.MyOrders;



---------------------------------------------------------------------
-- MERGE with OUTPUT
---------------------------------------------------------------------

MERGE INTO Sales.MyOrders AS TGT
USING (VALUES(1, 70, 1, '20151218'), (2, 70, 7, '20160429'), (3, 70, 7, '20160820'),
             (4, 70, 3, '20170114'), (5, 70, 1, '20170226'), (6, 70, 2, '20170410'))
       AS SRC(orderid, custid, empid, orderdate)
  ON SRC.orderid = TGT.orderid
WHEN MATCHED AND EXISTS( SELECT SRC.* EXCEPT SELECT TGT.* ) THEN
  UPDATE SET TGT.custid    = SRC.custid,
             TGT.empid     = SRC.empid,
             TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN
  INSERT VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE
OUTPUT
  $action AS the_action,
  COALESCE(inserted.orderid, deleted.orderid) AS orderid;

MERGE INTO Sales.MyOrders AS TGT
USING ( SELECT orderid, custid, empid, orderdate
        FROM Sales.Orders
        WHERE shipcountry = N'Norway' ) AS SRC
  ON 1 = 2
WHEN NOT MATCHED THEN
  INSERT(custid, empid, orderdate) VALUES(custid, empid, orderdate)
OUTPUT
  SRC.orderid AS srcorderid, inserted.orderid AS tgtorderid,
  inserted.custid, inserted.empid, inserted.orderdate;

-- clear table
TRUNCATE TABLE Sales.MyOrders;
ALTER SEQUENCE Sales.SeqOrderIDs RESTART WITH 1; 

