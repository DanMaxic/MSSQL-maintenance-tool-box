USE master;
GO
set transaction isolation level read uncommitted
GO

SELECT
	[DB_NAME]		= DB_NAME (qt.dbid)  
	,[OBJECT_NAME ]	= OBJECT_SCHEMA_NAME  (qt.objectid,qt.dbid)+'.'+OBJECT_NAME(qt.objectid,qt.dbid)
	,cp.objtype
	,qt.dbid
	,qt.objectid
	,qs.plan_generation_num
	,qs.execution_count
	,[TotalIO]		=(total_logical_reads+total_logical_writes)
	,[TotalCPU]		=(total_worker_time*0.001)	
	,[TotalDuration]=(total_elapsed_time*0.001)
	,[TotalBlocked]=((total_elapsed_time-total_worker_time)*0.001)
	,[AvgIO]		=cast(ROUND(	(total_logical_reads+total_logical_writes)/(execution_count+0.0),2) as decimal(20,3))
	,[AvgCPUTime]	=cast(ROUND(	((total_worker_time)+0.0)/(execution_count*1000) ,2)as decimal(20,3))
	,[AvgDuration]	=cast(ROUND(	((total_elapsed_time)+0.0)/(execution_count*1000) ,2)as decimal(20,3))
	,[AvgBlocked]	=cast(ROUND((	((total_elapsed_time)+0.0)/(execution_count*1000) -((total_worker_time)+0.0)/(execution_count*1000)),2)as decimal(20,3))

	,[query_text]	=( SUBSTRING(	qt.TEXT
								,qs.statement_start_offset/2 +1
								,(	CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
										ELSE qs.statement_end_offset 
									END - qs.statement_start_offset )/2 ) 
					)
					
	,qs.plan_handle
,cast(tqp.query_plan as XML)
FROM sys.dm_exec_query_stats qs 
	inner join sys.dm_exec_cached_plans  cp on  qs.plan_handle = cp.plan_handle
	CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) qt
	outer apply sys.dm_exec_text_query_plan(qs.sql_handle,qs.statement_start_offset, qs.statement_end_offset ) tqp
where OBJECT_NAME(qt.objectid,qt.dbid)='MD_GetDataByDataType'
ORDER BY [AvgCPUTime] DESC;
GO
