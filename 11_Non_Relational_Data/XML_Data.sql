USE WideWorldImporters
GO

/* XML DATA

-- Query XML data
-- Export as XML
-- FOR XML RAW
-- FOR XML PATH
-- FOR XML AUTO
-- OPEN XML
-- XML Data Type
-- VALIDATE XML
--------------------------------------------*/

-- Create XML example with FOR XML AUTO option, atttribute-centric
-- This query is used to produce the demo XML document at the beginning of the XML section
SELECT Customer.custid, Customer.companyname, 
  [Order].orderid, [Order].orderdate
FROM Sales.Customers AS Customer
  INNER JOIN Sales.Orders AS [Order]
    ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
  AND [Order].orderid %2 = 0
ORDER BY Customer.custid, [Order].orderid
FOR XML AUTO, ROOT('CustomersOrders');

/* FOR XML RAW
-- Basic
---------------------------------*/

SELECT Customer.custid, Customer.companyname, 
  [Order].orderid, [Order].orderdate
FROM Sales.Customers AS Customer
  INNER JOIN Sales.Orders AS [Order]
    ON Customer.custid = [Order].custid
WHERE Customer.custid <= 2
  AND [Order].orderid %2 = 0
ORDER BY Customer.custid, [Order].orderid
FOR XML RAW;

/* FOR XML AUTO
-- Element-centric, with namespace, root element
--------------------------------------------------------*/
WITH XMLNAMESPACES('ER70761-CustomersOrders' AS co)
SELECT [co:Customer].custid AS [co:custid], 
  [co:Customer].companyname AS [co:companyname], 
  [co:Order].orderid AS [co:orderid], 
  [co:Order].orderdate AS [co:orderdate]
FROM Sales.Customers AS [co:Customer]
  INNER JOIN Sales.Orders AS [co:Order]
    ON [co:Customer].custid = [co:Order].custid
WHERE [co:Customer].custid <= 2
  AND [co:Order].orderid %2 = 0
ORDER BY [co:Customer].custid, [co:Order].orderid
FOR XML AUTO, ELEMENTS, ROOT('CustomersOrders');

/* OPENXML
-- Rowset description in WITH clause
-------------------------------------------------*/
DECLARE @DocHandle AS INT;
DECLARE @XmlDocument AS NVARCHAR(1000);
SET @XmlDocument = N'
<CustomersOrders>
  <Customer custid="1">
    <companyname>Customer NRZBB</companyname>
    <Order orderid="10692">
      <orderdate>2015-10-03T00:00:00</orderdate>
    </Order>
    <Order orderid="10702">
      <orderdate>2015-10-13T00:00:00</orderdate>
    </Order>
    <Order orderid="10952">
      <orderdate>2016-03-16T00:00:00</orderdate>
    </Order>
  </Customer>
  <Customer custid="2">
    <companyname>Customer MLTDN</companyname>
    <Order orderid="10308">
      <orderdate>2014-09-18T00:00:00</orderdate>
    </Order>
    <Order orderid="10926">
      <orderdate>2016-03-04T00:00:00</orderdate>
    </Order>
  </Customer>
</CustomersOrders>';
-- Create an internal representation
EXEC sys.sp_xml_preparedocument @DocHandle OUTPUT, @XmlDocument;
-- Attribute- and element-centric mapping
-- Combining flag 8 with flags 1 and 2
SELECT *
FROM OPENXML (@DocHandle, '/CustomersOrders/Customer',11)
     WITH (custid INT,
           companyname NVARCHAR(40));
-- Remove the DOM
EXEC sys.sp_xml_removedocument @DocHandle;
GO

/* Querying XML data with XQuery
--------------------------------*/

-- XQuery with FLWOR Expressions
DECLARE @x AS XML = N'
<CustomersOrders>
  <Customer custid="1">
    <!-- Comment 111 -->
    <companyname>Customer NRZBB</companyname>
    <Order orderid="10692">
      <orderdate>2015-10-03T00:00:00</orderdate>
    </Order>
    <Order orderid="10702">
      <orderdate>2015-10-13T00:00:00</orderdate>
    </Order>
    <Order orderid="10952">
      <orderdate>2016-03-16T00:00:00</orderdate>
    </Order>
  </Customer>
  <Customer custid="2">
    <!-- Comment 222 -->  
    <companyname>Customer MLTDN</companyname>
    <Order orderid="10308">
      <orderdate>2014-09-18T00:00:00</orderdate>
    </Order>
    <Order orderid="10952">
      <orderdate>2016-03-04T00:00:00</orderdate>
    </Order>
  </Customer>
</CustomersOrders>';
SELECT @x.query('for $i in CustomersOrders/Customer/Order
                 let $j := $i/orderdate
                 where $i/@orderid < 10900
                 order by ($j)[1]
                 return 
                 <Order-orderid-element>
                  <orderid>{data($i/@orderid)}</orderid>
                  {$j}
                 </Order-orderid-element>')
       AS [Filtered, sorted and reformatted orders with let clause];
GO

/* The XML data type
---------------------*/

-- Using the XML data type for dynamic schema
ALTER TABLE Production.Products
 ADD additionalattributes XML NULL;
GO

-- Auxiliary tables
CREATE TABLE dbo.Beverages(percentvitaminsRDA INT); 
CREATE TABLE dbo.Condiments(shortdescription NVARCHAR(50)); 
GO 
-- Store the schemas in a variable and create the collection 
DECLARE @mySchema AS NVARCHAR(MAX) = N''; 
SET @mySchema +=
  (SELECT * 
   FROM Beverages 
   FOR XML AUTO, ELEMENTS, XMLSCHEMA('Beverages')); 
SET @mySchema +=
  (SELECT * 
   FROM Condiments 
   FOR XML AUTO, ELEMENTS, XMLSCHEMA('Condiments')); 
SELECT CAST(@mySchema AS XML);
CREATE XML SCHEMA COLLECTION dbo.ProductsAdditionalAttributes AS @mySchema; 
GO 
-- Drop auxiliary tables 
DROP TABLE dbo.Beverages, dbo.Condiments;
GO

-- Validate XML instances
ALTER TABLE Production.Products 
  ALTER COLUMN additionalattributes
   XML(dbo.ProductsAdditionalAttributes);
GO

-- Function to retrieve the namespace
CREATE FUNCTION dbo.GetNamespace(@chkcol AS XML)
 RETURNS NVARCHAR(15)
AS
BEGIN
 RETURN @chkcol.value('namespace-uri((/*)[1])','NVARCHAR(15)');
END;
GO
-- Function to retrieve the category name
CREATE FUNCTION dbo.GetCategoryName(@catid AS INT)
 RETURNS NVARCHAR(15)
AS
BEGIN
 RETURN 
  (SELECT categoryname 
   FROM Production.Categories
   WHERE categoryid = @catid);
END;
GO
-- Add the constraint
ALTER TABLE Production.Products ADD CONSTRAINT ck_Namespace
 CHECK (dbo.GetNamespace(additionalattributes) = 
        dbo.GetCategoryName(categoryid));
GO

-- Valid Data
-- Beverage
UPDATE Production.Products 
   SET additionalattributes = N'
<Beverages xmlns="Beverages"> 
  <percentvitaminsRDA>27</percentvitaminsRDA> 
</Beverages>'
WHERE productid = 1; 
-- Condiment
UPDATE Production.Products 
   SET additionalattributes = N'
<Condiments xmlns="Condiments"> 
  <shortdescription>very sweet</shortdescription> 
</Condiments>'
WHERE productid = 3; 
GO

-- Invalid Data
-- String instead of int
UPDATE Production.Products 
   SET additionalattributes = N'
<Beverages xmlns="Beverages"> 
  <percentvitaminsRDA>twenty seven</percentvitaminsRDA> 
</Beverages>'
WHERE productid = 1; 
-- Wrong namespace
UPDATE Production.Products 
   SET additionalattributes = N'
<Condiments xmlns="Condiments"> 
  <shortdescription>very sweet</shortdescription> 
</Condiments>'
WHERE productid = 2; 
-- Wrong element
UPDATE Production.Products 
   SET additionalattributes = N'
<Condiments xmlns="Condiments"> 
  <unknownelement>very sweet</unknownelement> 
</Condiments>'
WHERE productid = 3;
GO

-- Check the data
SELECT productid, productname, additionalattributes
FROM Production.Products
WHERE productid <= 3;
GO

-- Clean up
ALTER TABLE Production.Products
 DROP CONSTRAINT ck_Namespace;
ALTER TABLE Production.Products
 DROP COLUMN additionalattributes;
DROP XML SCHEMA COLLECTION dbo.ProductsAdditionalAttributes;
DROP FUNCTION dbo.GetNamespace;
DROP FUNCTION dbo.GetCategoryName;
GO