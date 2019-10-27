USE AdventureWorks2017
GO

/* find all comments pertaining to socks */

SELECT *
FROM Production.ProductReview
WHERE CONTAINS(Comments, 'socks');


/* other examples */
SELECT Title, [FileName]
FROM Production.Document
WHERE CONTAINS(*, 'reflector AND NOT seat');
