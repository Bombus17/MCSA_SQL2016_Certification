USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: T-SQL SELECT 

N.B.: In T-SQL the keyed order differs from the conceptual interpretation order.
The keyed order is inferred from the queries below. 

Interpretation Order
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY

-- SORTING DATA
--A table in TSL represents a relation; a relation is a set and a set has no order
--Therefore unless explicitly instructed to do so, the result of a query has no guaranteed order
-- ASC is the default
-- NULLS are sorted first
---------------------------------------------------------------------------------------*/
/* RETRIEVE A LIST OF ALL PREFERRED VENDORS 
-- Name is a reserved key word, hence enclosed in []
-- order alphabetically using ORDER BY clause (Default = ASC)
------------------------------------------------------------*/
SELECT [Name] 
      ,PreferredVendorStatus
      ,ActiveFlag
FROM [Purchasing].[Vendor]
WHERE PreferredVendorStatus = 1 AND ActiveFlag = 1
ORDER BY [Name] ; 

/* RETRIEVE A LIST OF ALL UNIQUE VENDORS 
-- DISTINCT removes duplicate records
-- notice the ordering
-----------------------------------------*/
SELECT DISTINCT [Name]  
FROM [Purchasing].[Vendor]

/* PRODUCE A LIST OF EMPLOYEES IN THE FOLLOWING FORMAT:
Title, First_Name, Middle_Name, Last_Name, Full_Name, Full_Name:Email_Promotion
-- use column aliasing
-- Use string concatenation to produce Full_Name column (must convert EmailPromotion from INT to VARCHAR(4))
-- alternatively use CONCAT function to automatically convert EmailPromotion 
-- N.B. NULLs are handled using CONCAT but not when using string concatenation
------------------------------------------------------------------------------*/
SELECT Title
      ,FirstName AS First_Name
      ,MiddleName AS Middle_Name
      ,LastName AS Last_Name
	  ,FirstName + ' ' + MiddleName + ' ' + LastName AS Full_Name
	  ,FirstName + ' ' + MiddleName + ' ' + LastName + ':' + CAST(EmailPromotion AS VARCHAR(2)) AS [Full_Name:EmailPromotion] -- using string concatenation
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName,' : ',EmailPromotion) AS [using_CONCAT]
FROM [Person].[Person];

/* ORDER THE EMPLOYEES LIST BY LASTNAME, FirstName 
-- can order by > 1 column
-----------------------------------------*/
SELECT Title
      ,FirstName AS First_Name
      ,MiddleName AS Middle_Name
      ,LastName AS Last_Name
	  ,FirstName + ' ' + MiddleName + ' ' + LastName + ':' + CAST(EmailPromotion AS VARCHAR(2)) AS [Full_Name:EmailPromotion] -- using string concatenation
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName,' : ',EmailPromotion) AS [using_CONCAT]
FROM [Person].[Person]
ORDER BY LastName, FirstName;

/* ORDER EMPLOYEE LIST BY EMAIL PROMOTION 
-- you do not need to select the column you are ordering by
-------------------------------------------------------------*/
SELECT Title
      ,FirstName AS First_Name
      ,MiddleName AS Middle_Name
      ,LastName AS Last_Name
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName) AS Full_Name
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName,' : ',EmailPromotion) AS [Full_Name:EmailPromotion]
FROM [Person].[Person]
ORDER BY EmailPromotion ;

/* ORDER EMPLOYEE LIST BY Full_Name 
-- due to the logical query processing order, aliases in the select list are visible to the ORDER BY clause
-----------------------------------*/
SELECT Title
      ,FirstName AS First_Name
      ,MiddleName AS Middle_Name
      ,LastName AS Last_Name
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName) AS Full_Name
	  ,CONCAT(FirstName,' ', MiddleName, '',LastName,' : ',EmailPromotion) AS [Full_Name:EmailPromotion]
FROM [Person].[Person]
ORDER BY Full_Name;

/* Logical query processing */

SELECT Gender, YEAR(hiredate) AS yearhired, COUNT(*) AS numemployees
FROM HumanResources.Employee
WHERE hiredate >= '20100101'
GROUP BY Gender, YEAR(hiredate)
HAVING COUNT(*) > 1
ORDER BY Gender, yearhired DESC;