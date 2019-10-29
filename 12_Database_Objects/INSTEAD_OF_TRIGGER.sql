USE AdventureWorks2017
GO


-- INSTEAD OF DML Trigger Example

CREATE TABLE dbo.TriggerTest
(
 FirstName varchar(15),
 LastName varchar(20),
 SSN char(11),
 State char(2)
)


-- Let's create an INSTEAD OF trigger that will 
-- fire when an INSERT occurs on this table
-- Note!
-- The INSTEAD OF trigger usually contains code 
-- to take some action before allowing the data insert to occur
-- or be refused...

CREATE TRIGGER io_TriggerEx
ON dbo.TriggerTest
INSTEAD OF INSERT
AS
BEGIN
  PRINT 'The INSTEAD OF trigger: io_TriggerEx has fired '
  PRINT 'The data contained in the INSERT command has not been added to the table'
END



select * from dbo.TriggerTest

-- Let's execute an INSERT and see the trigger in action
INSERT INTO dbo.TriggerTest
VALUES
('Bob','James','438-76-2362','TX')
