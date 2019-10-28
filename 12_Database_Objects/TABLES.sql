USE AdventureWorks2017
GO

/* TABLES

-- create tables
-- alter tables
-- impact of modifying tables
--------------------------------------------*/


---------------------------------------------------------------------
-- Adding a column
---------------------------------------------------------------------

-- Following fails
ALTER TABLE Sales.MyOrders ADD requireddate DATE NOT NULL;

-- Following succeeds
ALTER TABLE Sales.MyOrders
  ADD requireddate DATE NOT NULL
  CONSTRAINT DFT_MyOrders_requireddate DEFAULT ('19000101') WITH VALUES;

-- All rows have January 1st, 1900 in the requireddate column
SELECT * FROM Sales.MyOrders;

---------------------------------------------------------------------
-- Droping a column
---------------------------------------------------------------------

-- Following fails
ALTER TABLE Sales.MyOrders DROP COLUMN requireddate;

---------------------------------------------------------------------
-- Altering a column
---------------------------------------------------------------------

-- Following fails
ALTER TABLE Sales.MyOrders ALTER COLUMN requireddate DATETIME NOT NULL;

-- Following succeeds
ALTER TABLE Sales.MyOrders ALTER COLUMN requireddate DATE NULL;

-- Following succeeds as long as there are no NULLs in the column
ALTER TABLE Sales.MyOrders ALTER COLUMN requireddate DATE NOT NULL;

-- Drop default
ALTER TABLE Sales.MyOrders DROP CONSTRAINT DFT_MyOrders_orderid;

-- Add default
ALTER TABLE Sales.MyOrders ADD CONSTRAINT DFT_MyOrders_orderid
  DEFAULT(NEXT VALUE FOR Sales.SeqOrderIDs) FOR orderid;

-- cleanup
DROP TABLE IF EXISTS Sales.MyOrders;
DROP SEQUENCE IF EXISTS Sales.SeqOrderIDs;
