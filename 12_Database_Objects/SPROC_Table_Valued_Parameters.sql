-- Table-Valued Parameter Example

-- Here's the data we're going to work the first 20 product IDs
-- by passing them into a stored procedure using a table-valued parameter
select top 20 ProductID, SUM(quantity) 'In Stock'
 from production.productinventory
 GROUP BY ProductID


 -- Create a table type and define the structure
 -- of the table that we will use as a parameter
 CREATE TYPE InvInfoTable AS TABLE
 (
  ProdID int,
  Inventory int
 )


 -- Create a stored procedure that accepts
 -- our TVP and place any logic that you would like
 -- to run on the data being passed in by the TVP...
 -- We'll just create two result sets based on data ranges
 CREATE PROC GetInvTotal
 @InvTVP InvInfoTable READONLY
 AS
 SELECT ProdID, Inventory 'Inventory >950' from @InvTVP
 WHERE Inventory>950
 ORDER BY Inventory;

 SELECT ProdID, Inventory 'Inventory <950' from @InvTVP
  WHERE Inventory<950
 ORDER BY Inventory;

 -- Declare a table type variable named tInvParam and 
 -- reference the table type, then load data into the variable
 -- NOTE!
 -- Execute all the following code as a single batch
 -- You must use EXEC when calling the stored procedure

 DECLARE @tInvParam AS InvInfoTable

 INSERT INTO @tInvParam
 select top 20 ProductID, SUM(quantity) 'In Stock'
 from production.productinventory
 GROUP BY ProductID

 EXEC GetInvTotal @tInvParam