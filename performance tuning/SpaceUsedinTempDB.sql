SELECT
                    sys.dm_exec_sessions.session_id AS [SESSION ID],
                    DB_NAME(database_id) AS [DATABASE Name],
                    HOST_NAME AS [System Name],
                    program_name AS [Program Name],
                    login_name AS [USER Name],
                    status,
                    cpu_time AS [CPU TIME (in milisec)],
                    total_scheduled_time AS [Total Scheduled TIME (in milisec)],
                    total_elapsed_time AS    [Elapsed TIME (in milisec)],
                    (memory_usage * 8)      AS [Memory USAGE (in KB)],
                    (user_objects_alloc_page_count * 8)/1024 AS [SPACE Allocated FOR USER Objects (in MB)],
                    (user_objects_dealloc_page_count * 8)/1024 AS [SPACE Deallocated FOR USER Objects (in MB)],
                    (internal_objects_alloc_page_count * 8)/1024 AS [SPACE Allocated FOR Internal Objects (in MB)],
                    (internal_objects_dealloc_page_count * 8)/1024 AS [SPACE Deallocated FOR Internal Objects (in MB)],
                    CASE is_user_process
                                         WHEN 1      THEN 'user session'
                                         WHEN 0      THEN 'system session'
                    END         AS [SESSION Type], row_count AS [ROW COUNT]
FROM sys.dm_db_session_space_usage
                                         INNER join
                    sys.dm_exec_sessions
                                         ON sys.dm_db_session_space_usage.session_id = sys.dm_exec_sessions.session_id
										-- WHERE (internal_objects_alloc_page_count * 8) >( 1024 * 1024)	--BY GB
										 WHERE (internal_objects_alloc_page_count * 8) >( 1024)		--BY MB

--OBJECT USED IN TEMPDB
--===================================
	SELECT 
			OBJECT_NAME(p.object_id),
			p.row_count,
			(p.reserved_page_count * 8 ) AS [SPACE Allocated FOR Internal Objects (in KB)],
			*
		FROM tempdb.sys.dm_db_partition_stats p
		INNER JOIN tempdb.sys.tables t
		ON p.object_id = t.object_id
		
		 WHERE t.is_ms_shipped = 0 AND (p.reserved_page_count * 8 )>1024