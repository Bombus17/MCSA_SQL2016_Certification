
-- Creating indexes

-- Let's create a test table
-- Create a new table with three columns.  
CREATE TABLE dbo.TestTable  
    (TestCol1 int NOT NULL,  
     TestCol2 nchar(10) NULL,  
     TestCol3 nvarchar(50) NULL);  


-- Now, let's create a clustered index called IX_TestTable_TestCol1  
-- on the dbo.TestTable table using the TestCol1 column.  
CREATE CLUSTERED INDEX IX_TestTable_TestCol1   
    ON dbo.TestTable (TestCol1);   
GO  

-- We can also create a non-clustered index
CREATE NONCLUSTERED INDEX IX_TestTable_TestCol2   
    ON dbo.TestTable (TestCol2); 


-- Creating indexes graphically
/*

1. Right click the table in Object Explorer, choose Design

2. Right click a column, choose Indexes/Keys

3. Complete the wizard.
