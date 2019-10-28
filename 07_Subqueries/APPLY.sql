USE [AdventureWorks2017]
GO

/*------------------------------------------------------------------------------------
Purpose: APPLY OPERATOR

-- APPLY
-- CROSS APPLY
-- OUTER APPLY
-- logical processing aspects
-- optimisation  when using apply operators

TODO: finish this script
---------------------------------------------------------------------------------------*/

/* APPLY OPERATOR 

----------------------------------*/

---------------------------------------------------------------------
-- The APPLY operator
---------------------------------------------------------------------

-- add a supplier from Japan
INSERT INTO Production.Suppliers
  (companyname, contactname, contacttitle, address, city, postalcode, country, phone)
  VALUES(N'Supplier XYZ', N'Jiru', N'Head of Security', N'42 Sekimai Musashino-shi',
         N'Tokyo', N'01759', N'Japan', N'(02) 4311-2609');

-- two products with lowest unit prices for given supplier
SELECT TOP (2) productid, productname, unitprice
FROM Production.Products
WHERE supplierid = 1
ORDER BY unitprice, productid;

-- CROSS APPLY
-- two products with lowest unit prices for each supplier from Japan
-- exclude suppliers without products
SELECT S.supplierid, S.companyname AS supplier, A.*
FROM Production.Suppliers AS S
  CROSS APPLY (SELECT TOP (2) productid, productname, unitprice
               FROM Production.Products AS P
               WHERE P.supplierid = S.supplierid
               ORDER BY unitprice, productid) AS A
WHERE S.country = N'Japan';

-- OUTER APPLY
-- two products with lowest unit prices for each supplier from Japan
-- include suppliers without products
SELECT S.supplierid, S.companyname AS supplier, A.*
FROM Production.Suppliers AS S
  OUTER APPLY (SELECT TOP (2) productid, productname, unitprice
               FROM Production.Products AS P
               WHERE P.supplierid = S.supplierid
               ORDER BY unitprice, productid) AS A
WHERE S.country = N'Japan';

-- cleanup
DELETE FROM Production.Suppliers WHERE supplierid > 29;

/*  -- CROSS APPLY 
-- right table expression applied to each row from left input
-- if right table expression returns an empty set for the left row
-- the left row isn't returned (see also OUTER APPLY)


OUTER APPLY 
-- extends cross apply
-- includes rows from the left table that return an empty set
-- NULLs as placeholders
-- preserves LEFT side
--APPLY operator is required when you have to use a table-valued function in the query, 
-- but it can also be used with inline SELECT statements

*/