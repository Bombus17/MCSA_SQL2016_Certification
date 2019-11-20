USE AdventureWorks2017
GO


/*				COLUMN STORE INDEXES

--a method of storing, retrieving, and managing data by using a COLUMNAR DATA FORMAT

--CLUSTERED COLUMNSTORE INDEX 
	- primary storage for the entire table
	--Use a clustered columnstore index to store fact tables and large dimension tables for data warehousing workloads
--NON CLUSTERED COLUMNSTORE INDEX
	--secondary index that's created on a rowstore table
	--nonclustered index contains a copy of part or all of the rows and columns in the underlying table
	--Use a nonclustered columnstore index to perform analysis in real time on an OLTP workload

-- there are DATA TYPE restrictions on COLUMNSTORE INDEXES
--NOT: text/ntext/image/nvarchar(max)/varchar(max)/varbinary(max)
		rowversion/sql_variant/CLR types, xml, uniqueidentifier

--All of the columns in a columnstore index are stored in the metadata as included columns. 
	--The columnstore index DOESN'T HAVE KEY COLUMNS
--Data is logically organized as a table with rows and columns, and physically stored in a column-wise data format
--A ROWGROUP
	--a group of rows that are compressed into columnstore format at the same time
	--For high performance and high compression rates, the columnstore index slices the table into rowgroups
	-- then compresses each rowgroup in a column-wise manner
--COLUMN SEGMENT
	--column of data from within the rowgroup

--Each rowgroup contains one column segment for every column in the table.
--Each column segment is compressed together and stored on physical media

--A clustered columnstore index is the physical storage for the entire table
--Rows in the index but not in the column store are in the DELTA STORE

--Reasons why columnstore indexes are so fast:

--Columns store values from the same domain and commonly have similar values
	which result in high compression rates. I/O bottlenecks in your system are minimized or eliminated
	and memory footprint is reduced significantly.

--High compression rates improve query performance by using a smaller in-memory footprint. 
	In turn, query performance can improve because SQL Server can perform more query and data operations in memory.

--Batch execution improves query performance, typically by two to four times, by processing multiple rows together.

--Queries often select only a few columns from a table, which reduces total I/O from the physical media

----------------------------------------------------------------*/

/*  VIEW METADATA */

sys.indexes
sys.index_columns
sys.partitions
sys.column_store_segments
sys.column_store_row_groups
sys.dm_db_column_store_row_group_physical_stats
sys.dm_db_column_store_row_group_operational_stats
sys.dm_db_index_physical_stats

/* column store segments 
----------------------------------------------------*/
SELECT i.name, p.object_id, p.index_id, i.type_desc,   
    COUNT(*) AS number_of_segments  
FROM sys.column_store_segments AS s   
INNER JOIN sys.partitions AS p   
    ON s.hobt_id = p.hobt_id   
INNER JOIN sys.indexes AS i   
    ON p.object_id = i.object_id  
WHERE i.type = 5 OR i.type = 6  
GROUP BY i.name, p.object_id, p.index_id, i.type_desc ;

/* column store row groups
---------------------------------*/
SELECT i.object_id, object_name(i.object_id) AS TableName,   
i.name AS IndexName, i.index_id, i.type_desc,   
CSRowGroups.*,   
100*(total_rows - ISNULL(deleted_rows,0))/total_rows AS PercentFull    
FROM sys.indexes AS i  
JOIN sys.column_store_row_groups AS CSRowGroups  
    ON i.object_id = CSRowGroups.object_id  
AND i.index_id = CSRowGroups.index_id   
--WHERE object_name(i.object_id) = '<table_name>'   
ORDER BY object_name(i.object_id), i.name, row_group_id;  

/* create table as a columnstore 
----------------------------------*/
CREATE CLUSTERED COLUMNSTORE INDEX [indexnam] ON [dbo].[tblname] 
WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
       WITH (DROP_EXISTING = ON);


-- MAXDOP degree of parallelism
CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
       WITH (MAXDOP = 2);

-- compression delay
CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
       WITH ( COMPRESSION_DELAY = 10 Minutes );

-- data compression
CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
       WITH ( DATA_COMPRESSION = COLUMNSTORE_ARCHIVE );

-- ON/OFFLINE
CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
       WITH ( ONLINE = ON );


/* NON CLUSTERED 
----------------------------------*/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCS_indexname] ON [dbo].[tblname]
(
   [column selected for the index]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
GO

CREATE COLUMNSTORE INDEX ncci ON Sales.OrderLines (StockItemID, Quantity, UnitPrice, TaxRate) WITH ( ONLINE = ON );

/* EXPLORE ROWGROUP
---------------------------------*/
SELECT * FROM sys.dm_db_column_store_row_group_physical_stats


/* DELTA STORE 

Delta Rowgroups work with columnstore indexes. They are useful to improve columnstore compression and performance by storing records based on a threshold number. When the maximum number is reached in a Delta Rowgroup, it closes that group and compresses the rowgroups and stores in a Columstore.
A set of delta rowgroups are collectively called the Deltastore.
A Deltastore is temporary storage for a clustered index.
Deltastore improves performance and will reduce fragmentation of column segments.
A columnstore index uses Deltastore to retrieve correct query requests.
A columnstore index can have more than one delta rowgroup.
-------------------------------------------------------------*/

/* RESTRICTIONS 
-- see MS Docs for full details

-- cannot be combined with page/row compression
	replication
	Filestream
	computed columns
-----------------------*/

/* system views to see metadata */

sys.indexes 
sys.index_columns 
sys.partitions 
sys.column_store_segments 
sys.column_store_dictionaries
sys.column_store_row_groups 

SELECT i.name AS index_name  
    ,COL_NAME(ic.object_id,ic.column_id) AS column_name  
    ,ic.index_column_id  
    ,ic.key_ordinal  
,ic.is_included_column  
FROM sys.indexes AS i  
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
WHERE i.object_id = OBJECT_ID('Production.BillOfMaterials');  

 