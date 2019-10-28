USE WideWorldImporters
GO

/* INLINE TABLE VALUED FUNCTIONS

--TO DO: finalise and test
--------------------------------*/


---------------------------------------------------------------------
-- Inline Table-Valued Functions
---------------------------------------------------------------------

-- management chain leading to given employee
DROP FUNCTION IF EXISTS HR.GetManagers;
GO
CREATE FUNCTION HR.GetManagers(@empid AS INT) RETURNS TABLE
AS

RETURN
  WITH EmpsCTE AS
  (
    SELECT empid, mgrid, firstname, lastname, 0 AS distance
    FROM HR.Employees
    WHERE empid = @empid

    UNION ALL

    SELECT M.empid, M.mgrid, M.firstname, M.lastname, S.distance + 1 AS distance
    FROM EmpsCTE AS S
      JOIN HR.Employees AS M
        ON S.mgrid = M.empid
  )
  SELECT empid, mgrid, firstname, lastname, distance
  FROM EmpsCTE;
GO

SELECT *
FROM HR.GetManagers(9) AS M;

-- cleanup
DROP VIEW IF EXISTS Sales.RankedProducts;
DROP FUNCTION IF EXISTS HR.GetManagers;