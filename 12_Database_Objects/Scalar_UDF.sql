USE AdventureWorks2017
GO

-- Scalar UDF Example
-- We will create a function to provide a more 
-- descriptive result set for the EmailPromotion column
-- in the Person.EmailAddress table
SELECT * FROM Person.Person

-- Create a function named fnEmailPromo
-- It will accept EmailAddress as an input and
-- return a string value based on the int value
-- being passed in
-- We will use the function in a select statement
CREATE FUNCTION fnEmailPromo (@promo int)
RETURNS varchar(20)
AS
BEGIN
DECLARE @ret_promo varchar(20)
select @ret_promo=
	CASE 
		WHEN @promo=0 then 'None'
		WHEN @promo=1 then 'Local'
		WHEN @promo=2 THEN 'National'
		ELSE 'Not designated'
	END
	RETURN @ret_promo
END

-- Now, let's user our new fnEmailPromo function
-- Note that to call the new function we must include
-- dbo. in the name
SELECT FirstName + ' ' + Lastname Customer, dbo.fnEmailPromo(EmailPromotion) 'Promotion Type'
FROM Person.Person
ORDER BY LastName, FirstName

