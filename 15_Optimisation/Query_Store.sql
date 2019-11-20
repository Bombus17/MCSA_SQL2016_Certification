USE AdventureWorks2017
go

/*  QUERY STORE

--simplifies performance troubleshooting by helping you quickly find performance differences caused by query plan changes. 
		Query Store automatically captures a history of queries, plans, and runtime statistics, and retains these for your review. 
	It separates data by time windows so you can see database usage patterns and understand when query plan changes happened on the server.
-- cannot be set for master or tempdb
-- REVIEW QUERY STORE BEST PRACTICES and keep it adjusted to your workload

-- PLANS
-- collects plans for DML statements
-- does not collect plans for Natively compiled stored procedures

 USES
--Quickly find and fix a plan performance regression by forcing the previous query plan. Fix queries that have recently regressed in performance due to execution plan changes.
--Determine the number of times a query was executed in a given time window, assisting a DBA in troubleshooting performance resource problems.
--Identify top n queries (by execution time, memory consumption, etc.) in the past x hours.
--Audit the history of query plans for a given query.
--Analyze the resource (CPU, I/O, and Memory) usage patterns for a particular database.
--Identify top n queries that are waiting on resources.
--Understand wait nature for a particular query or plan

-- STORES
-- PLAN STORE for persisting the execution plan information.
-- RUNTIME STATS STORE for persisting the execution statistics information.
-- WAIT STATS STORE for persisting wait statistics information
------------------------------------------------------------*/
/* Enable Query Store */
----------------------------------------
ALTER DATABASE AdventureWorks2017 
SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE);

/* set multiple query store options 
-----------------------------------*/ 
ALTER DATABASE <database name>   
SET QUERY_STORE (  
    OPERATION_MODE = READ_WRITE,  
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),  
    DATA_FLUSH_INTERVAL_SECONDS = 3000,  
    MAX_STORAGE_SIZE_MB = 500,  
    INTERVAL_LENGTH_MINUTES = 15,  
    SIZE_BASED_CLEANUP_MODE = AUTO,  
    QUERY_CAPTURE_MODE = AUTO,  
    MAX_PLANS_PER_QUERY = 1000,
    WAIT_STATS_CAPTURE_MODE = ON 
);

/* Retrieve information about query plans 
------------------------------------------------*/
SELECT Txt.query_text_id, Txt.query_sql_text, Pl.plan_id, Qry.*  
FROM sys.query_store_plan AS Pl  
INNER JOIN sys.query_store_query AS Qry  
    ON Pl.query_id = Qry.query_id  
INNER JOIN sys.query_store_query_text AS Txt  
    ON Qry.query_text_id = Txt.query_text_id ; 

/* determine query type and use sql_handle 
-------------------------------------------*/
SELECT * FROM sys.databases;   
SELECT * FROM sys.fn_stmt_sql_handle_from_sql_stmt('SELECT * FROM sys.databases', NULL);

/* Query store catalog views 
-------------------------------*/
sys.database_query_store_options 	
sys.query_context_settings 
sys.query_store_plan 	
sys.query_store_query 
sys.query_store_query_text 	
sys.query_store_runtime_stats 
sys.query_store_wait_stats 	
sys.query_store_runtime_stats_interval 

/* Manage Query Store
-------------------------*/
SELECT actual_state, actual_state_desc, readonly_reason,   
    current_storage_size_mb, max_storage_size_mb  
FROM sys.database_query_store_options; 

/* get query store options */
SELECT * FROM sys.database_query_store_options;

/* set query store interval */
ALTER DATABASE <database_name>   
SET QUERY_STORE (INTERVAL_LENGTH_MINUTES = 15);

/* check space usage */
SELECT current_storage_size_mb, max_storage_size_mb   
FROM sys.database_query_store_options;

/* extend storage */
ALTER DATABASE <database_name>   
SET QUERY_STORE (MAX_STORAGE_SIZE_MB = <new_size>);

/* delete ad hoc queries (executed only once and older than 24 hours */
--------------------------------------------------------
DECLARE @id int  
DECLARE adhoc_queries_cursor CURSOR   
FOR   
SELECT q.query_id  
FROM sys.query_store_query_text AS qt  
JOIN sys.query_store_query AS q   
    ON q.query_text_id = qt.query_text_id  
JOIN sys.query_store_plan AS p   
    ON p.query_id = q.query_id  
JOIN sys.query_store_runtime_stats AS rs   
    ON rs.plan_id = p.plan_id  
GROUP BY q.query_id  
HAVING SUM(rs.count_executions) < 2   
AND MAX(rs.last_execution_time) < DATEADD (hour, -24, GETUTCDATE())  
ORDER BY q.query_id ;  
  
OPEN adhoc_queries_cursor ;  
FETCH NEXT FROM adhoc_queries_cursor INTO @id;  
WHILE @@fetch_status = 0  
    BEGIN   
        PRINT @id  
        EXEC sp_query_store_remove_query @id  
        FETCH NEXT FROM adhoc_queries_cursor INTO @id  
    END   
CLOSE adhoc_queries_cursor ;  
DEALLOCATE adhoc_queries_cursor;

