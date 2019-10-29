USE AdventureWorks2017
GO

-- AFTER Trigger Example

-- Let's create a simple table 
CREATE TABLE AfterTrigTest
(
 FirstName varchar(15),
 LastName varchar(20),
 SSN varchar(11),
 State char(2)
)

-- Insert two rows into the table
INSERT INTO AfterTrigTest
VALUES
('Bob','James','484-52-6462','TN'),
('Ann','Lesley','492-67-5234','AZ')

-- Create an AFTER UPDATE trigger on the AfterTrigTest table
CREATE TRIGGER trAfterTrigTest_upd
ON AfterTrigTest
AFTER UPDATE
AS
BEGIN
PRINT  CONVERT(varchar(5),@@rowcount) + ' row(s) were updated.'
+ CHAR(13) + CHAR(13) + 'This rowcount was provided by the trAfterTrigTest trigger...'
--ROLLBACK TRANSACTION
END


-- Perform an update to test the trigger
UPDATE AfterTrigTest
SET FirstName='Robert'
WHERE FirstName='Bob'


select * from AfterTrigTest