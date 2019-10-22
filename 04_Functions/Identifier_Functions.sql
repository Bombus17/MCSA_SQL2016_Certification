USE AdventureWorks2017
GO

/* IDENTIFIER FUNCTIONS

--system functions for identifying the connecting environment or the data itsel

-- NEWSEQUENTIALID(): 
-- NEWID(): 
-- @@IDENTITY
-- SCOPE_IDENTITY
-- IDENT_CURRENT

---------------------------------------------------*/

/* functions that can be used as keys for rows.

-- NEWID(): globally unique, even across systems
-- has a UNIQUEIDENTIFIER typed value
----------------------------------------------------*/

SELECT NEWID() AS MyGUID;

/* Use NEWSEQUENTIALID() system function to ensure the GUID always increases
-- within the machine
-- this function can't be invoked separately.
-- It is defined in an expression in a default constraint associated with a column
--------------------------------------------------*/

/* NUMERIC KEY GENERATOR 

-- USE CREATE SEQUENCE Command, using NEXT VALUE FOR <sequence name> to invoke the function
-----------------------------------------------------*/

/* SCOPE_IDENTITY()
-- returns the last identity value taht was generated in the same session and scope
----------------------------------------------------*/

/* @@INDENTITY()
-- returns the last identity value generated in the session (irrespective of scope)

