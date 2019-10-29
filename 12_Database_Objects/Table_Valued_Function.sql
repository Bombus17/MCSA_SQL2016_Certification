USE AdventureWorks2017
GO


-- TVF Example

-- Here are the three tables we will be getting our data from
select top 1 * from person.person
select top 1 * from person.emailaddress
select top 1 * from humanresources.employee

-- Our TVF will return the names and email addresses of our
-- employees based on their gender
-- Let's create our TVF

CREATE FUNCTION dbo.fnGetEmail(@gender char(1))
RETURNS TABLE
AS
RETURN
	SELECT p.FirstName, p.Lastname,e.EmailAddress,em.Gender
	FROM person.person p
	JOIN person.EmailAddress e on p.BusinessEntityID=e.BusinessEntityID
	JOIN HumanResources.Employee em on e.BusinessEntityID=em.BusinessEntityID
	WHERE em.Gender=@gender

-- Let's use our TVF
SELECT * FROM dbo.fnGetEmail('m')


-- We can add a WHERE clause to get more creative with the results
SELECT * FROM dbo.fnGetEmail('m')
WHERE LastName LIKE 'D%'




