USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: multiple Joins 

-- conceptual evaluation
-- best practices when using different join types
-- pitfalls when ordering mixed joins in queries
-- joining to derived tables
-- self referencing joins

-- Composite Joins 
-- JOIN operators (AND OR)
-- Using NULLs in joins (see Handling_NULLs script)


---------------------------------------------------------------------------------------*/

/* MULTIPLE JOINS

-- it is more common to have joins on > 2 tables at a time
-- SQL processes these joins from left to right
-- ordering joins incorrectly has pitfalls in returning data due to NULL placeholders in OUTER joins
-- when using different join types consider the ordering
-- INNER JOINs should preceed OUTER JOINs to prevent cancelling out the placeholders

------------------------------------------------------------------------------------*/

/* Placing an OUTER join first

-- here the NULL placholders are cancelled out by the subsequent INNER JOIN
-- Note: these examples are both representative of composite joins (joining on > 1 column) and using JOIN operators
----------------------------------------------------------------------------*/
SELECT p.BusinessEntityID
, p.PersonType
, p.NameStyle
, p.Title
, p.FirstName
, p.MiddleName
, p.LastName
, pp.PhoneNumber
, pnt.[Name] AS NumberType
FROM Person.Person p
LEFT OUTER JOIN Person.PersonPhone pp 
	ON p.BusinessEntityID = pp.BusinessEntityID
INNER JOIN Person.PhoneNumberType pnt 
	ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
	AND pnt.PhoneNumberTypeID = 3

/* INNER JOIN first
-- SQL processes from L to R
-- here the NULL placholders are preserved as the INNER JOIN occurs first
--Note: these examples are both representative of composite joins (joining on > 1 column) and using JOIN operators
----------------------------------------------------------------------------*/
SELECT p.BusinessEntityID
, p.PersonType
, p.NameStyle
, p.Title
, p.FirstName
, p.MiddleName
, p.LastName
, pp.PhoneNumber
, pnt.[Name] AS NumberType
FROM Person.Person p
INNER JOIN Person.PersonPhone pp 
	ON p.BusinessEntityID = pp.BusinessEntityID
LEFT OUTER JOIN Person.PhoneNumberType pnt 
	ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
	AND pnt.PhoneNumberTypeID = 3


