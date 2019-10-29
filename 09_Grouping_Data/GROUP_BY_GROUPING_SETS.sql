USE AdventureWorks2017
go


/* GROUPING SETS OPERATOR

-- WHEN: need to include different combinations of GROUP BY expressions in the same result set
-- used instead of using a UNION ALL to combine groups at all levels

-----------------------------------------*/

/* retrieve company Income per year
----------------------------*/

SELECT
	YEAR(OrderDate) AS OrderYear,
	SUM(SubTotal) AS Income
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;

/* grouup by year and month to get further details */
SELECT
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	SUM(SubTotal) AS Income
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

/* get the same data but grouped by grouping sets 

-- note the NULL for each year, gives a year total
--------------------------------------------------*/
SELECT
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	SUM(SubTotal) AS Incomes
FROM Sales.SalesOrderHeader
GROUP BY
	GROUPING SETS
	(
		YEAR(OrderDate), --1st grouping set
		(YEAR(OrderDate),MONTH(OrderDate)) --2nd grouping set
	);


/* income per year, month and overall

-- note NULL placeholders for sub total and grand total
-------------------------------------------*/

SELECT
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	SUM(SubTotal) AS Incomes
FROM Sales.SalesOrderHeader
GROUP BY
	GROUPING SETS
	(
		YEAR(OrderDate), --1st grouping set
		(YEAR(OrderDate),MONTH(OrderDate)), --2nd grouping set
		() --3rd grouping set (grand total)
	);
