USE AdventureWorks2017
GO

/* TRANSACTIONS

-- A Transaction is a unit of work
-- It should have ACID properties
-- Transactions should be isolated either at the session or query level
-- Defining Transactions
-- SAVEPOINTS

------------------------------*/
/* TEST TABLE */
------------------------------
SELECT * INTO Person.PersonTest
FROM Person.Person

/* ---------------------------
	DEFINING TRANSACTIONS

-- Using a named transaction here
-- if you don't explicitly define the transaction 
-- SQL Server uses an autocommit mode where each individual statement is considered a separate transaction
-- Note: Assigning values to variables and modifying data in table variables are not transactional operations
----------------------------*/

BEGIN TRANSACTION DefTran;

DECLARE @NewBusEntityID AS INT, @BusEntityID AS INT
SELECT @BusEntityID = MAX(BusinessEntityID)+1 FROM Person.PersonTest;

INSERT INTO [Person].[PersonTest]
           ([BusinessEntityID]
           ,[PersonType]
           ,[NameStyle]
           ,[Title]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[Suffix]
           ,[EmailPromotion]
           ,[AdditionalContactInfo]
           ,[Demographics]
           ,[rowguid]
           ,[ModifiedDate])

VALUES (@BusEntityID,'VC',0,'Mrs','Paula',NULL,'Alexander',NULL,0,NULL,NULL,'2370A8B3-97FD-49A1-ABA3-C2F61FD5BCEA',GETDATE());

SET @NewBusEntityID = SCOPE_IDENTITY();

PRINT 'Added new row with BusinessEntityID ' + CAST(@NewBusEntityID as VARCHAR(10)) + '. @@TRANCOUNT is: ' + CAST(@@TRANCOUNT AS VARCHAR(10)) + '.';

COMMIT TRANSACTION DefTran;

SELECT *
FROM Person.PersonTest
WHERE FirstName = 'Paula' and LastName = 'Alexander';

-- Let's start a transaction and perform a sloppy UPDATE
BEGIN TRAN TestTran
UPDATE Person.PersonTest
SET LastName='Jones';

-- Let's see the damage...
select * from person.persontest;

-- Let's rollback the transaction and remove the modifications
-- from the transaction log
ROLLBACK TRAN TestTran;

-- Now, let's perform the UPDATE correctly
BEGIN TRAN TestTran;

UPDATE person.persontest
SET LastName='Miller'
WHERE Lastname='Jones' and FirstName='Dylan';

COMMIT TRAN TestTran;


/* 
	SAVEPOINTS
-- A marker within an open transaction that you can later roll back to
-- this will undo all changes up to that savepoint
-- on rolling back to the savepoint the transaction remains open and the code continues to execution
-- you must be in an open transaction to mark a savepoint
-- multiple savepoints are allowed within a transaction
--------------------------------------------------------------------------------------*/

