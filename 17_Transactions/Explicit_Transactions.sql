
-- Explicit Transactions

-- Let's use SELECT INTO to create a test
-- table called PersonTest
SELECT * INTO Person.PersonTest
FROM Person.Person

-- Let's start a transaction and perform a sloppy UPDATE
BEGIN TRAN TestTran
UPDATE Person.PersonTest
SET LastName='Jones'

-- Let's see the damage...
select * from person.persontest

-- Let's rollback the transaction and remove the modifications
-- from the transaction log
ROLLBACK TRAN TestTran

-- Now, let's perform the UPDATE correctly

BEGIN TRAN TestTran

UPDATE person.persontest
SET LastName='Miller'
WHERE Lastname='Jones' and FirstName='Dylan'

COMMIT TRAN TestTran

