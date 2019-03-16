			 /*

SELECT   DB_Name(database_id)  ,
*
FROM sys.master_files	WHERE type = 1	
DBCC SQLPERF (LOGSPACE)

	*/
CREATE TABLE #tmptable
(
	DBname			nvarchar(128)
	,DBfile			NCHAR(1024)
	,[TotalLogsize(MB)]		DECIMAL
	,[LogSpaceUsed%]	DECIMAL
	,STATUS			INT	   
)
INSERT INTO #tmptable
        ( DBname ,
          [TotalLogsize(MB)] ,
          [LogSpaceUsed%] ,
          STATUS
        )
EXEC ('DBCC SQLPERF (LOGSPACE)')

ALTER TABLE #tmptable   ADD [FreeSpaceMB] AS    CONVERT  (INT,([TotalLogsize(MB)]*(100-[LogSpaceUsed%])/100))

SELECT 
		TB1.DBname,TB2.name,
			   (SELECT recovery_model_desc FROM sys.databases WHERE name = TB1.DBname)
		,TB2.physical_name,[TotalLogsize(MB)],([TotalLogsize(MB)]-[FreeSpaceMB])AS [UsedSize MB],[FreeSpaceMB],[LogSpaceUsed%] 
		,
			CASE	
							WHEN TB2.growth > 100 THEN	(SELECT	CONVERT(sysname, (growth/128))+ ' MB')
							ELSE					(SELECT	CONVERT(sysname, (growth))+ ' %')
					
					END	   AS 'Auto Grow',
		'Use ['+TB1.DBname+']; DBCC SHRINKFILE (['+TB2.name+'], 1000);'
FROM
	 #tmptable			AS TB1,
	 sys.master_files	AS TB2
WHERE 
	(TB1.DBname =DB_NAME(TB2.database_id))
	AND
		(TB2.type = 1)		  
	--AND TB1.DBname = 'EQ_HST' 
	ORDER BY 6 desc 

DROP TABLE #tmptable

--EXEC master.sys.xp_fixeddrives
/*DBCC SQLPERF (LOGSPACE)
========================================================
WHAT CONSUMIN in TemDB Log
========================================================

;WITH task_space_usage AS (
    -- SUM alloc/delloc pages
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count) AS alloc_pages,
           SUM(internal_objects_dealloc_page_count) AS dealloc_pages
    FROM sys.dm_db_task_space_usage WITH (NOLOCK)
    WHERE session_id <> @@SPID
    GROUP BY session_id, request_id
)
SELECT TSU.session_id,
       TSU.alloc_pages * 1.0 / 128 AS [internal object MB space],
       TSU.dealloc_pages * 1.0 / 128 AS [internal object dealloc MB space],
       EST.text,
       -- Extract statement from sql text
       ISNULL(
           NULLIF(
               SUBSTRING(
                 EST.text, 
                 ERQ.statement_start_offset / 2, 
                 CASE WHEN ERQ.statement_end_offset < ERQ.statement_start_offset 
                  THEN 0 
                 ELSE( ERQ.statement_end_offset - ERQ.statement_start_offset ) / 2 END
               ), ''
           ), EST.text
       ) AS [statement text],
       EQP.query_plan
FROM task_space_usage AS TSU
INNER JOIN sys.dm_exec_requests ERQ WITH (NOLOCK)
    ON  TSU.session_id = ERQ.session_id
    AND TSU.request_id = ERQ.request_id
OUTER APPLY sys.dm_exec_sql_text(ERQ.sql_handle) AS EST
OUTER APPLY sys.dm_exec_query_plan(ERQ.plan_handle) AS EQP
WHERE EST.text IS NOT NULL OR EQP.query_plan IS NOT NULL
ORDER BY 2 DESC;


*/
/**

	SELECT tdt.database_transaction_log_bytes_reserved,tst.session_id,
		   t.[text], [statement] = COALESCE(NULLIF(
			 SUBSTRING(
			   t.[text],
			   r.statement_start_offset / 2,
			   CASE WHEN r.statement_end_offset < r.statement_start_offset
				 THEN 0
				 ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
			 ), ''
		   ), t.[text])
		 FROM sys.dm_tran_database_transactions AS tdt
		 INNER JOIN sys.dm_tran_session_transactions AS tst
		 ON tdt.transaction_id = tst.transaction_id
			 LEFT OUTER JOIN sys.dm_exec_requests AS r
			 ON tst.session_id = r.session_id
			 OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
     WHERE tdt.database_id = 2;

*/

 -- 
 --DBCC SHRINKFILE (templog, 15000) WITH NO_INFOMSGS

/*

;WITH s AS
(
    SELECT 
        s.session_id,
        [pages] = SUM(s.user_objects_alloc_page_count 
          + s.internal_objects_alloc_page_count) 
    FROM sys.dm_db_session_space_usage AS s
    GROUP BY s.session_id
    HAVING SUM(s.user_objects_alloc_page_count 
      + s.internal_objects_alloc_page_count) > 0
)
SELECT s.session_id, s.[pages], t.[text], 
  [statement] = COALESCE(NULLIF(
    SUBSTRING(
        t.[text], 
        r.statement_start_offset / 2, 
        CASE WHEN r.statement_end_offset < r.statement_start_offset 
        THEN 0 
        ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
      ), ''
    ), t.[text])
FROM s
LEFT OUTER JOIN 
sys.dm_exec_requests AS r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
ORDER BY s.[pages] DESC;


dbcc opentran
DBCC SQLPERF(logspace)
DBCC LOGINFO

select	name
		,state_desc
		,snapshot_isolation_state_desc
		,is_read_committed_snapshot_on
		,log_reuse_wait_desc
		,recovery_model_desc
		,is_cdc_enabled
from sys.databases where name = 'EQ_HST'

DBCC DBINFO('EQ_HST') WITH TABLERESULTS


SELECT * FROM sys.dm_tran_database_transactions
WHERE [database_transaction_status] & 0x80000 = 0x80000;

select * from sys.databases

*/
