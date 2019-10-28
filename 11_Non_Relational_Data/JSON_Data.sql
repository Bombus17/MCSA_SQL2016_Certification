USE WideWorldImporters
GO

/* JSON Data

-- Query JSON
-- Output JSON
-- FOR JSON AUTO
-- FOR JSON PATH
-- Dot Aliases
-- Remove parentheses
-- Add Root element
-- Handle NULL
-- Handle Arrays
-- OPEN JSON
-- Convert to Tabular format
-- $lax and $strict modes
-- update, amend, delete items
-- check with ISJSON

TODO: further testing
-------------------------------*/



-- Create JSON example with FOR JSON AUTO option
-- This query is used to produce the demo JSON document
SELECT Customer.custid, Customer.companyname, 
  [Order].orderid, [Order].orderdate
FROM Sales.Customers AS Customer
  INNER JOIN Sales.Orders AS [Order]
    ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
  AND [Order].orderid %2 = 0
ORDER BY Customer.custid, [Order].orderid
FOR JSON AUTO;

-- Format the results with JSON formatter
-- e.g., https://jsonformatter.curiousconcept.com/
/* Formatted result
[
   {
      "custid":1,
      "companyname":"Customer NRZBB",
      "Order":[
         {
            "orderid":10692,
            "orderdate":"2015-10-03"
         },
         {
            "orderid":10702,
            "orderdate":"2015-10-13"
         },
         {
            "orderid":10952,
            "orderdate":"2016-03-16"
         }
      ]
   },
   {
      "custid":2,
      "companyname":"Customer MLTDN",
      "Order":[
         {
            "orderid":10308,
            "orderdate":"2014-09-18"
         },
         {
            "orderid":10926,
            "orderdate":"2016-03-04"
         }
      ]
   }
]
*/

-- FOR JSON PATH - simple
SELECT TOP (2) custid, companyname, contactname
FROM Sales.Customers
ORDER BY custid
FOR JSON PATH;

-- Using dot
SELECT custid AS [CustomerId], 
  companyname AS [Company], 
  contactname AS [Contact.Name]
FROM Sales.Customers
WHERE custid = 1
FOR JSON PATH;

-- Dot aliases with multiple tables
SELECT c.custid AS [Customer.Id], 
  c.companyname AS [Customer.Name], 
  o.orderid AS [Order.Id], 
  o.orderdate AS [Order.Date]
FROM Sales.Customers AS c
  INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
WHERE c.custid = 1
  AND o.orderid = 10692
ORDER BY c.custid, o.orderid
FOR JSON PATH;

-- Dot aliases with multiple tables, orders nested
SELECT c.custid AS [Customer.Id], 
  c.companyname AS [Customer.Name], 
  o.orderid AS [Customer.Order.Id], 
  o.orderdate AS [Customer.Order.Date]
FROM Sales.Customers AS c
  INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
WHERE c.custid = 1
  AND o.orderid = 10692
ORDER BY c.custid, o.orderid
FOR JSON PATH;

-- Remove brackets
SELECT c.custid AS [Customer.Id], 
  c.companyname AS [Customer.Name], 
  o.orderid AS [Customer.Order.Id], 
  o.orderdate AS [Customer.Order.Date]
FROM Sales.Customers AS c
  INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
WHERE c.custid = 1
  AND o.orderid = 10692
ORDER BY c.custid, o.orderid
FOR JSON PATH,
    WITHOUT_ARRAY_WRAPPER;

-- Add a root element
SELECT c.custid AS [Customer.Id], 
  c.companyname AS [Customer.Name], 
  o.orderid AS [Customer.Order.Id], 
  o.orderdate AS [Customer.Order.Date]
FROM Sales.Customers AS c
  INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
WHERE c.custid = 1
  AND o.orderid = 10692
ORDER BY c.custid, o.orderid
FOR JSON PATH,
    ROOT('Customer 1');

-- Add a null
SELECT c.custid AS [Customer.Id], 
  c.companyname AS [Customer.Name], 
  o.orderid AS [Customer.Order.Id], 
  o.orderdate AS [Customer.Order.Date],
  NULL AS [Customer.Order.Delivery]
FROM Sales.Customers AS c
  INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
WHERE c.custid = 1
  AND o.orderid = 10692
ORDER BY c.custid, o.orderid
FOR JSON PATH,
    WITHOUT_ARRAY_WRAPPER,
    INCLUDE_NULL_VALUES;

---------------------------------------------------------------------
-- Convert JSON data to tabular format
---------------------------------------------------------------------

-- OPENJSON with implicit schema
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
   "Customer":{ 
      "Id":1, 
      "Name":"Customer NRZBB",
      "Order":{ 
         "Id":10692, 
         "Date":"2015-10-03",
         "Delivery":null
      }
   }
}';
SELECT *
FROM OPENJSON(@json);
GO

-- OPENJSON with path
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
   "Customer":{ 
      "Id":1, 
      "Name":"Customer NRZBB",
      "Order":{ 
         "Id":10692, 
         "Date":"2015-10-03",
         "Delivery":null
      }
   }
}';
SELECT *
FROM OPENJSON(@json,'$.Customer');
GO

-- lax and strict mode
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
  "Customer":{ 
      "Name":"Customer NRZBB"
      }
}';
SELECT *
FROM OPENJSON(@json,'lax $.Buyer');
SELECT *
FROM OPENJSON(@json,'strict $.Buyer');
GO

-- OPENJSON with explicit schema
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
   "Customer":{ 
      "Id":1, 
      "Name":"Customer NRZBB",
      "Order":{ 
         "Id":10692, 
         "Date":"2015-10-03",
         "Delivery":null
      }
   }
}';
SELECT *
FROM OPENJSON(@json)
WITH
(
 CustomerId   INT           '$.Customer.Id',
 CustomerName NVARCHAR(20)  '$.Customer.Name',
 Orders       NVARCHAR(MAX) '$.Customer.Order' AS JSON
);
GO

-- JSON_VALUE and JSON_QUERY
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
   "Customer":{ 
      "Id":1, 
      "Name":"Customer NRZBB",
      "Order":{ 
         "Id":10692, 
         "Date":"2015-10-03",
         "Delivery":null
      }
   }
}';
SELECT JSON_VALUE(@json, '$.Customer.Id') AS CustomerId,
 JSON_VALUE(@json, '$.Customer.Name') AS CustomerName,
 JSON_QUERY(@json, '$.Customer.Order') AS Orders;
GO

-- JSON_MODIFY
DECLARE @json AS NVARCHAR(MAX) = N'
{ 
   "Customer":{ 
      "Id":1, 
      "Name":"Customer NRZBB",
      "Order":{ 
         "Id":10692, 
         "Date":"2015-10-03",
         "Delivery":null
      }
   }
}'; 
-- Update name  
SET @json = JSON_MODIFY(@json, '$.Customer.Name', 'Modified first name'); 
-- Delete Id  
SET @json = JSON_MODIFY(@json, '$.Customer.Id', NULL)  
-- Insert last name  
SET @json = JSON_MODIFY(@json, '$.Customer.LastName', 'Added last name')  
PRINT @json;
GO

-- ISJSON
SELECT ISJSON ('str') AS s1,  ISJSON ('') AS s2, 
  ISJSON ('{}') AS s3,  ISJSON ('{"a"}') AS s4, 
  ISJSON ('{"a":1}') AS s5;
GO
