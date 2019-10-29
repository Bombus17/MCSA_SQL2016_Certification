
-- Savepoints Example

-- Let's create a very simple table
CREATE TABLE TranTest
(
    Name VARCHAR(15)
)

select * from trantest

-- Let's modify the table using two transactions
BEGIN TRAN T1
   INSERT INTO TranTest VALUES ('Mark')
   PRINT 'First Transaction: ' + CONVERT(VARCHAR,@@TRANCOUNT)

 BEGIN TRAN T2
     INSERT INTO TranTest VALUES ('Janet')
     PRINT 'Second Transaction: ' + CONVERT(VARCHAR,@@TRANCOUNT)
 
ROLLBACK TRAN T1 -- This will rollback BOTH transactions
PRINT 'Remaining Transactions: ' + CONVERT(VARCHAR,@@TRANCOUNT)
 
COMMIT TRAN

-- Transactions cannot be nested...
-- What happens if you have a stored procedure or trigger that contains a 
-- transaction that is rolled back?
-- If the process calling the procedure also uses a transaction, 
-- it's transaction could be unexpectedly rolled back by the stored procedure!
-- Unless you use savepoints...

select * from trantest

-- Let's use a savepoint
BEGIN TRAN
PRINT 'First Transaction: ' + CONVERT(VARCHAR,@@TRANCOUNT)
INSERT INTO TranTest VALUES ('Mark')
 
SAVE TRAN Savepoint1   -- Sets a savepoint and begins a 2nd transaction
PRINT 'Second Transaction: ' + CONVERT(VARCHAR,@@TRANCOUNT)
 
INSERT INTO TranTest VALUES ('Janet')
 
ROLLBACK TRAN Savepoint1
PRINT 'Rollback: ' + CONVERT(VARCHAR,@@TRANCOUNT)
 
COMMIT TRAN
PRINT 'Complete: ' + CONVERT(VARCHAR,@@TRANCOUNT)