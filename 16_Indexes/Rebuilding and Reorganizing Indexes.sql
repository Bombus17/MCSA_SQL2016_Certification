-- Managing Indexes

-- Execute this query  
-- Uses sys.dm_db_index_physical_stats
-- Change the database name and table name as needed
SELECT a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2012'), 
OBJECT_ID(N'HumanResources.Employee'), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;   

-- To reorganize an index
ALTER INDEX IX_Employee_OrganizationalLevel_OrganizationalNode ON HumanResources.Employee  
REORGANIZE;

-- To reorganize all indexes on a table
ALTER INDEX ALL ON HumanResources.Employee  
REORGANIZE;

-- To rebuild an index
ALTER INDEX PK_Employee_BusinessEntityID ON HumanResources.Employee
REBUILD;


-- To manage an index using graphical tools in SSMS

-- Expand a table in SSMS Object Explorer

-- Expand the Indexes folder

-- Right click the index to be reorganized/rebuilt



