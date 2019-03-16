
/*
SELECT
[owt].[blocking_session_id],
	[owt].[session_id],
	[es].[login_time],
	[es].host_name,
	[es].program_name,
	[es].login_name,
	[es].status,

	[owt].[exec_context_id],
	[owt].[wait_duration_ms],
	[owt].[wait_type],
	
	[owt].[resource_description],
	[est].[text],
	[est].[dbid],
	[eqp].[query_plan],
	[es].[cpu_time],
	[es].[memory_usage]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_exec_sessions [es] ON
	[owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
	[es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE [es].[is_user_process] = 1 and owt.wait_type !='BROKER_RECEIVE_WAITFOR'
ORDER BY [owt].[session_id], [owt].[exec_context_id]
GO

*/

select 
       [es].[session_id],
--es
       [es].[host_name],
	   [ec].[client_net_address],
       [es].[program_name],
	   [es].[login_name],

 --er
       [er].[status],
       [er].[command],
       [er].[blocking_session_id],
       [er].[wait_type],
       [er].[wait_resource],
       [er].[wait_time],
	   [er].[last_wait_type],
       [er].[percent_complete],
       [er].[estimated_completion_time],
       [er].[transaction_id],
       [er].[open_transaction_count],
       [er].[transaction_isolation_level],
       [er].[prev_error],

--MG
       [es].[memory_usage],
       [mg].[granted_memory_KB],
       [mg].[ideal_memory_kb],
--tdt
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
FROM         sys.dm_exec_requests                           [er]
INNER JOIN sys.dm_exec_sessions                             [es]        on  [es].[session_id] = [er].[session_id]
INNER JOIN sys.dm_tran_database_transactions                [tdt]       on  [er].[transaction_id] = [tdt].[transaction_id]
INNER JOIN sys.dm_exec_query_memory_grants					[mg]        on  [mg].[session_id] = [er].[session_id]
inner join sys.dm_exec_connections							[ec]		on	[ec].[session_id] =[er].[session_id] 
OUTER APPLY sys.dm_exec_sql_text ([er].[plan_handle])		[est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle])		[eqp]

--where [er].[session_id] = 343




--where [er].[session_id] = 343

--select * from sys.dm_exec_requests order by 1

--dm_exec_connections 

