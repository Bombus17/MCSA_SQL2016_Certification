
-- Output Parameters Example
-- Let's create a stored proc that will return
-- the current inventory level for a product id


-- Let's take a look at the data we will use
select * from production.productinventory

-- Let's create our stored procedure and output variable
ALTER PROC CI
@ProdID int,
@InStk int OUTPUT
AS
SELECT @InStk=       
	SUM(pi.Quantity)
FROM            
    Production.ProductInventory pi
WHERE pi.ProductID=@ProdID

RETURN


-- Now, let's call our stored proc 
DECLARE @Inv int;
EXEC CI 1,@Instk=@Inv OUTPUT
PRINT 'Current inventory is: ' + CONVERT(varchar(6),@Inv)