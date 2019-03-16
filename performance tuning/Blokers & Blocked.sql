
set transaction isolation level read uncommitted
go


----Blocked
select [es].[session_id],
	   [es].[host_process_id],
       [es].[host_name],
	   [ec].[client_net_address],
	   [es].[program_name],
	   [es].[login_name],
	   [es].[status],
       [er].[command],
       [er].[blocking_session_id],
	   [es].last_request_start_time,
       [er].[wait_type],
       [er].[wait_resource],
       [er].[wait_time],
	   [er].[last_wait_type],
       [er].[percent_complete],
       [er].[estimated_completion_time],
       [er].[transaction_id],
       [er].[open_transaction_count],
       [transaction_isolation_level] = CASE ([er].[transaction_isolation_level])
			WHEN 0	THEN 'Unspecified'
			WHEN 1	THEN 'ReadUncomitted'
			WHEN 2	THEN 'ReadCommitted'
			WHEN 3	THEN 'Repeatable'
			WHEN 4	THEN 'Serializable'
			WHEN 5	THEN 'Snapshot'  
	   END,
       [er].[prev_error],
	   [er].cpu_time,
	   [er].logical_reads,
	   [er].open_resultset_count,
	   [er].writes,
--MG
       [es].[memory_usage],
       [mg].[granted_memory_KB],
	   [mg].requested_memory_kb,
       --[mg].[ideal_memory_kb],
	   db_name([tdt].[database_id]) [Transaction_Related_DB],
       CASE [tdt].[database_transaction_state]
              WHEN 1 THEN 'Read/Write'
              WHEN 2 THEN 'Read only'
              WHEN 3 THEN 'System' END AS TransactionType,
              CASE database_transaction_state
              WHEN 1 THEN 'Not Initialized'
              WHEN 3 THEN 'Transaction No Log'
              WHEN 4 THEN 'Transaction with Log'
              WHEN 5 THEN 'Transaction Prepared'
              WHEN 10 THEN 'Commited'
              WHEN 11 THEN 'Rolled Back'
              WHEN 12 THEN 'Commited and Log Generated' END AS [database_transaction_state],
       [tdt].[database_transaction_replicate_record_count],
       [tdt].[database_transaction_log_bytes_reserved] ,
	   ([TaskSpaceUsed].user_objects_alloc_page_count + [TaskSpaceUsed].internal_objects_alloc_page_count)*8 AS user_objects_alloc_KB
	   ,[TaskSpaceUsed].internal_objects_alloc_page_count
	   ,[TaskSpaceUsed].user_objects_alloc_page_count
	  ,[OBJECT_NAME ]	= OBJECT_SCHEMA_NAME  ([est].objectid,[est].dbid)+'.'+OBJECT_NAME([est].objectid,[est].dbid)
       ,(SELECT TOP 1 SUBSTRING([est].[text],statement_start_offset / 2+1 , 
      ( (CASE WHEN statement_end_offset = -1 
         THEN (LEN(CONVERT(nvarchar(max),[est].[text])) * 2) 
         ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS sql_statement,
       [eqp].[query_plan]
	   into #Blocked
FROM  sys.dm_exec_sessions [es]
Left join sys.dm_exec_requests								[er]			on	[es].[session_id] = [er].[session_id]
Left JOIN sys.dm_tran_database_transactions					[tdt]			on  [er].[transaction_id] = [tdt].[transaction_id]
Left JOIN sys.dm_exec_query_memory_grants					[mg]			on  [mg].[session_id] = [es].[session_id]
Left join sys.dm_exec_connections							[ec]			on	[ec].[session_id] =[es].[session_id] 
Left Join sys.dm_db_task_space_usage						[TaskSpaceUsed] on  [TaskSpaceUsed].[session_id] = [es].[session_id]  
outer APPLY sys.dm_exec_sql_text ([er].[plan_handle])		[est]
outer APPLY sys.dm_exec_query_plan ([er].[plan_handle])		[eqp]
where [es].[is_user_process] in(1)
--AND [ec].[client_net_address] = '172.21.101.00'
--and [es].host_name not in ( 'ws-danmax','WS-DANIELS')
--AND [ec].[client_net_address] like '172.20.%'
--AND [es].[session_id] =61
AND [er].[blocking_session_id] is not null
--and [tdt].[internal_objects_alloc_page_count] >0
--AND  db_name([er].database_id) = 'DataX'
--AND  [er].[last_wait_type]!='BROKER_RECEIVE_WAITFOR'
--AND 	   [es].[login_name] = 'DbAdmin'
order by 1 asc

----------------------------- kill 90

select 'Blockers'
----Blockers
select [es].[session_id],
	[es].[host_process_id],
       [es].[host_name],
	   [ec].[client_net_address],
	   [es].[program_name],
	   [es].[login_name],
	   [es].[status],
       [er].[command],
       [er].[blocking_session_id],
	   [es].last_request_start_time,
       [er].[wait_type],
       [er].[wait_resource],
       [er].[wait_time],
	   [er].[last_wait_type],
       [er].[percent_complete],
       [er].[estimated_completion_time],
       [er].[transaction_id],
       [er].[open_transaction_count],
       [transaction_isolation_level] = CASE ([er].[transaction_isolation_level])
			WHEN 0	THEN 'Unspecified'
			WHEN 1	THEN 'ReadUncomitted'
			WHEN 2	THEN 'ReadCommitted'
			WHEN 3	THEN 'Repeatable'
			WHEN 4	THEN 'Serializable'
			WHEN 5	THEN 'Snapshot'  
	   END,
       [er].[prev_error],
	   [er].cpu_time,
	   [er].logical_reads,
	   [er].open_resultset_count,
	   [er].writes,
--MG
       [es].[memory_usage],
       [mg].[granted_memory_KB],
      -- [mg].[ideal_memory_kb],
	   db_name([tdt].[database_id]) [Transaction_Related_DB],
       CASE [tdt].[database_transaction_state]
              WHEN 1 THEN 'Read/Write'
              WHEN 2 THEN 'Read only'
              WHEN 3 THEN 'System' END AS TransactionType,
              CASE database_transaction_state
              WHEN 1 THEN 'Not Initialized'
              WHEN 3 THEN 'Transaction No Log'
              WHEN 4 THEN 'Transaction with Log'
              WHEN 5 THEN 'Transaction Prepared'
              WHEN 10 THEN 'Commited'
              WHEN 11 THEN 'Rolled Back'
              WHEN 12 THEN 'Commited and Log Generated' END AS [database_transaction_state],
       [tdt].[database_transaction_replicate_record_count],
       [tdt].[database_transaction_log_bytes_reserved] ,
       (SELECT TOP 1 SUBSTRING([est].[text],statement_start_offset / 2+1 , 
      ( (CASE WHEN statement_end_offset = -1 
         THEN (LEN(CONVERT(nvarchar(max),[est].[text])) * 2) 
         ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS sql_statement,
       [eqp].[query_plan]
FROM  sys.dm_exec_sessions [es]
Left join sys.dm_exec_requests								[er]		on	[es].[session_id] = [er].[session_id]
Left JOIN sys.dm_tran_database_transactions					[tdt]       on  [er].[transaction_id] = [tdt].[transaction_id]
Left JOIN sys.dm_exec_query_memory_grants					[mg]        on  [mg].[session_id] = [es].[session_id]
Left join sys.dm_exec_connections							[ec]		on	[ec].[session_id] =[es].[session_id] 
outer APPLY sys.dm_exec_sql_text ([er].[plan_handle])		[est]
outer APPLY sys.dm_exec_query_plan ([er].[plan_handle])		[eqp]
where  [es].[is_user_process] = 1
--AND [ec].[client_net_address] = '172.21.101.63'
--and [es].host_name = 'ws-danmax'
--AND [ec].[client_net_address] like '172.20.%'
AND [es].[session_id] in (select [blocking_session_id] from #Blocked where [blocking_session_id] is not null AND [blocking_session_id] <> 0)
--AND [er].[blocking_session_id] is not null
order by [blocking_session_id]

select 'Blocked'
select * from #Blocked where [blocking_session_id] is not null AND [blocking_session_id] <> 0

drop table #Blocked;