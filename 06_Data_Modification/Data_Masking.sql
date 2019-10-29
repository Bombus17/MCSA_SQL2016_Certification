
--Dynamic Data Masking Demo

-- Let's create an email mask on the EmailAddress
-- column in the Person.EmailAddress table
ALTER TABLE Person.EmailAddress
ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'email()') --NULL);  

-- Create a user named Bob to test our masking and
-- Grant Bob the SELECT permissions on the Person.EmailAddress table
CREATE USER Bob WITHOUT LOGIN;
GRANT SELECT ON Person.EmailAddress TO Bob


-- Select data from the Person.EmailAddress table
-- using Bob's account
EXECUTE AS USER = 'Bob'
select * from person.emailaddress
REVERT;


-- Now, let's take a look at using a custom string mask
-- We'll mask the NatitonalIDNumber column in the
-- HumanResources.Employee table

-- Here's what the NationalIDNumber column looks like unmasked
-- This query will be executed by my MLong user account with
-- sysadmin privileges
select * from HumanResources.Employee

-- Let's add the custom string mask to the NationalIDNumber column
-- by performing an ALTER TABLE command on the table
ALTER TABLE HumanResources.Employee
ALTER COLUMN NationalIDNumber ADD MASKED WITH (FUNCTION = 'partial(1,"xxx",4)')

-- Grant the SELECT permission to our test user Bob
GRANT SELECT ON HumanResources.Employee TO Bob

-- Execute a SELECT statement as Bob to see the masking
EXECUTE AS USER = 'Bob'
select * from HumanResources.Employee
REVERT;