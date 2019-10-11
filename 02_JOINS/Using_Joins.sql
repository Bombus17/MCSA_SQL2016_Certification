USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: JOINS

-- Correct use of Joins
-- INNER JOIN
-- LEFT/RIGHT/FULL OUTER JOIN
-- CROSS JOIN
-- JOIN operators (AND OR)
-- Using NULLs in joins

TODO: finish this script
---------------------------------------------------------------------------------------*/


SELECT TOP 5 * from Production.Product    -- There are 508 rows in this table

SELECT TOP 5 * from Production.ProductReview   -- There are 4 rows in this table



-- This query will perform an INNER JOIN
SELECT p.Name, pr.ProductReviewID
FROM Production.Product p 
JOIN Production.ProductReview pr
ON p.ProductID = pr.ProductID


-- This query will perform a LEFT JOIN
SELECT p.Name, pr.ProductReviewID
FROM Production.Product p
LEFT OUTER JOIN Production.ProductReview pr
ON p.ProductID = pr.ProductID


-- This query will perform a RIGHT JOIN
SELECT p.Name, pr.ProductReviewID
FROM Production.Product p
RIGHT OUTER JOIN Production.ProductReview pr
ON p.ProductID = pr.ProductID


SELECT p.Name, pr.ProductReviewID
FROM Production.Product p
CROSS JOIN Production.ProductReview pr