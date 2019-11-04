USE AdventureWorks2017
GO

/*	ERROR HANDLING

-- Error Handling
-- TRY CATCH
-- THROW and RAISERROR
-- ERROR_NUMBER: the internal number of the error 
-- ERROR_STATE: integer in range 1-255. used for custom purposes.
-- ERROR_SEVERITY: severity number
-- ERROR_LINE: line number at which an error occured  
-- ERROR_PROCEDURE: name of the stored procedure or function, returns NULL if error was not at a stored procedure
-- ERROR_MESSAGE: most essential information and that is the message text of the error 
-- Transactions: BEGIN...END, COMMIT TRANSACTION, ROLLBACK TRANSACTION (see Transactions scripts)
-- XACT_STATE
-- SET_XACT_ABORT (ON | OFF)
-- ARITHABORT, ARITHINGNORE, ANSI_WARNINGS
-- @@ROWCOUNT
-- @@TRANCOUNT

FURTHER READING: 
Quite old but a very good overview: http://www.sommarskog.se/error-handling-I.html
---------------------------------------*/


/* TRY CATCH

SYNTAX
	BEGIN TRY  
		 --code to try 
	END TRY  
	BEGIN CATCH  
		 --code to run if error occurs
	--is generated in try
	END CATCH

-- Place code in TRY block
-- Error handling on the CATCH block
-- If there's no error in the TRY block, the CATCH block is skipped
-- If there is an error in the TRY block, control is passed to the first line of the CATCH block
Note:
-- You may nest a TRY-CATCH construct within a CATCH block
-- If an error happens in a CATCH block, which is not in a nested TRY-CATCH construct
	the error behaves as if it didn't happend in a TRY block; i.e. it bubbles it up
-- The block can't catch compilation errors (e.g. referring to columns that don't exist) in the same scope
	Can catch such errors in an outer scope

--------------------------------------------------*/

BEGIN TRY
-- Generate a divide-by-zero error  
	SELECT
		1 / 0 AS Error;
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH;


-- Table to record errors
 
CREATE TABLE DB_Errors
				 (ErrorID        INT IDENTITY(1, 1),
				  UserName       VARCHAR(100),
				  ErrorNumber    INT,
				  ErrorState     INT,
				  ErrorSeverity  INT,
				  ErrorLine      INT,
				  ErrorProcedure VARCHAR(MAX),
				  ErrorMessage   VARCHAR(MAX),
				  ErrorDateTime  DATETIME
				  ) ON [PRIMARY]
			GO
/* produce error */
---------------------------------------
ALTER PROCEDURE dbo.AddSale @employeeid INT,
									 @productid  INT,
									 @quantity   SMALLINT,
									 @saleid     UNIQUEIDENTIFIER OUTPUT
AS
SET @saleid = NEWID()
	BEGIN TRY
		INSERT INTO Sales.Sales
				 SELECT
					 @saleid,
					 @productid,
					 @employeeid,
					 @quantity
	END TRY
	BEGIN CATCH
		INSERT INTO dbo.DB_Errors
		VALUES
	(SUSER_SNAME(),
	 ERROR_NUMBER(),
	 ERROR_STATE(),
	 ERROR_SEVERITY(),
	 ERROR_LINE(),
	 ERROR_PROCEDURE(),
	 ERROR_MESSAGE(),
	 GETDATE());
	END CATCH
GO

/* GENERATE CUSTOM ERRORS
------------------------------*/

ALTER PROCEDURE dbo.AddSale @employeeid INT,
									 @productid  INT,
									 @quantity   SMALLINT,
									 @saleid     UNIQUEIDENTIFIER OUTPUT
AS
SET @saleid = NEWID()
	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO Sales.Sales
				 SELECT
					 @saleid,
					 @productid,
					 @employeeid,
					 @quantity
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		INSERT INTO dbo.DB_Errors
		VALUES
	(SUSER_SNAME(),
	 ERROR_NUMBER(),
	 ERROR_STATE(),
	 ERROR_SEVERITY(),
	 ERROR_LINE(),
	 ERROR_PROCEDURE(),
	 ERROR_MESSAGE(),
	 GETDATE());
 
-- Transaction uncommittable
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
 
-- Transaction committable
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
	END CATCH
GO

/* AMENDED 
-------------------*/

ALTER PROCEDURE dbo.AddSale @employeeid INT,
									 @productid  INT,
									 @quantity   SMALLINT,
									 @saleid     UNIQUEIDENTIFIER OUTPUT
AS
SET @saleid = NEWID()
	BEGIN TRY
	IF (SELECT COUNT(*) FROM HumanResources.Employee e WHERE employeeid = @employeeid) = 0
		  RAISEERROR ('EmployeeID does not exist.', 11, 1)
		
		INSERT INTO Sales.Sales
				 SELECT
					 @saleid,
					 @productid,
					 @employeeid,
					 @quantity
	END TRY
	BEGIN CATCH
		INSERT INTO dbo.DB_Errors
		VALUES
	(SUSER_SNAME(),
	 ERROR_NUMBER(),
	 ERROR_STATE(),
	 ERROR_SEVERITY(),
	 ERROR_LINE(),
	 ERROR_PROCEDURE(),
	 ERROR_MESSAGE(),
	 GETDATE());
 
	 DECLARE @Message varchar(MAX) = ERROR_MESSAGE(),
				@Severity int = ERROR_SEVERITY(),
				@State smallint = ERROR_STATE()
 
	 RAISEERROR (@Message, @Severity, @State)
	END CATCH
GO