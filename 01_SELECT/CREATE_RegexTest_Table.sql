USE ADVENTUREWORKS2017
GO

/*---------------------------------------------------------------------------------------
Purpose: Create test data for SELECT_Alpha_REGEX.sql

--------------------------------------------------------------------------------------*/
IF OBJECT_ID('dbo.RegexTest', 'U') IS NOT NULL
  DROP TABLE dbo.RegexTest
GO

CREATE TABLE RegexTest(
   AlphaCol NVARCHAR(200)
)
 
INSERT INTO RegexTest 
VALUES ('Learn how to query temporal data and non-relational data.')
   , ('To write correct and ROBUST T-SQL code, it''s important to first understand the roots of the language.')
   , ('Logical Query Processing Order.')
   , ('XML data processing is very straightforward')
   , ('2')
   , ('An understanding of how indexes work is fundamental to writing performant queries.')
   , ('Be aware of how NULLs are handled!') 
   , ('1. FROM, 2. WHERE, 3. GROUP BY, 4. HAVING, 5. SELECT, 6. ORDER BY')
   , ('What is a set?')
   , ('In the words of Georg Canor; "By a set we meany any collection of M into a whole of definite, distinct objects m (which are called the elements of M").') 
   , ('Remember that a relation has a heading and a body. The heading has a set of attributes and the body is a set of tuples.') 
   , ('A')
   , ('C')
   , ('Gg')
   , ('Uneccessary CAPITALISATION.')
   , ('BD')
   , ('Implement Error handling using TRY-CATCH.')
   , ('T-SQL is a declarative English-like language.')
   , ('Five?')
   , ('Query multiple tables using joins')
   , ('Learn how to implement functions and aggregate data.')
   , ('SEVEN')
   , ('"Yes"')
   , ('T-SQL is based on SQL, which in turn is based on the realtional model')
   , (' SQL Server ')
 
SELECT *
FROM RegexTest