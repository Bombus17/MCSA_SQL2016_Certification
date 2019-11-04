USE AdventureWorks2017
GO

/*-----------------------------------------
	THROW and RAISERROR
-- Allow you to raise a user defined error
-- Only THROW allows you to rethrow an original error that was caught in a TRY-CATCH construct

-- THROW
-- 2 supported syntaxes
1. without parameters: use command in CATCH block to re-throw the error
	the rethrown error behaves like the original one
	if the failure generates a chain or error messages
	the rethrown error does too. 
--------------------------------------------*/