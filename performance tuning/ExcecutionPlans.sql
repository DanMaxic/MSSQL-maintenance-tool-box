Declare @ProcName varchar(128);
set @ProcName = 'MD_GetDataByDataType_HST';

SELECT
top 500
	[DB_NAME]		= ISNULL(DB_NAME(qt.dbid),'ResourceDB')
	,[OBJECT_NAME ]	= OBJECT_SCHEMA_NAME  (qt.objectid,qt.dbid)+'.'+OBJECT_NAME(qt.objectid,qt.dbid)
	,cp.objtype
	,qt.dbid
	--,plan_generation_num
	--,statement_start_offset
	--,query_hash
	,execution_count

	--,qt.objectid
	,[last_elapsed_time Sec] = (last_elapsed_time/1000000.0)
	,last_logical_writes
	,last_physical_reads
	,last_logical_reads
	
	,[Avg Duration]	=cast(ROUND(	((total_elapsed_time)+0.0)/(execution_count*1000000) ,2)as decimal(20,3))
	,[Avg Reads]		=cast(ROUND(	(total_logical_reads+total_physical_reads)/(execution_count+0.0),2) as decimal(20,3))
	,[AvgCPUTime]	=cast(ROUND(	((total_worker_time)+0.0)/(execution_count*1000000) ,2)as decimal(20,3))

	,[query_text]	=( SUBSTRING(	qt.TEXT
								,qs.statement_start_offset/2 +1
								,(	CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
										ELSE qs.statement_end_offset 
									END - qs.statement_start_offset )/2 ) 
					)
,cast(tqp.query_plan as XML)
FROM sys.dm_exec_query_stats qs 
	inner join sys.dm_exec_cached_plans  cp on  qs.plan_handle = cp.plan_handle
	CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) qt
	outer apply sys.dm_exec_text_query_plan(qs.plan_handle,qs.statement_start_offset, qs.statement_end_offset ) tqp
where 
	(last_elapsed_time/1000000.0) >1
ORDER BY qs.statement_start_offset asc

;

return
/*
SELECT text, plan_handle, d.usecounts, d.cacheobjtype 
FROM sys.dm_exec_cached_plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
CROSS APPLY 
 	sys.dm_exec_cached_plan_dependent_objects(plan_handle) d;
	*/



	SELECT 
			[DB_NAME]		= ISNULL(DB_NAME(p.database_id),'ResourceDB')
			,[OBJECT_NAME ]	= OBJECT_SCHEMA_NAME  (p.object_id,p.database_id)+'.'+OBJECT_NAME(p.object_id,p.database_id)
			,cached_time
			,last_execution_time
			,execution_count
			,[last_elapsed_time Sec] = (last_elapsed_time/1000000.0)
			,last_logical_writes
			,last_physical_reads
			,last_logical_reads
			,[Avg Duration]	=cast(ROUND(	((total_elapsed_time)+0.0)/(execution_count*1000000) ,2)as decimal(20,3))
			,[Avg Reads]		=cast(ROUND(	(total_logical_reads+total_physical_reads)/(execution_count+0.0),2) as decimal(20,3))
			,[AvgCPUTime]	=cast(ROUND(	((total_worker_time)+0.0)/(execution_count*1000000) ,2)as decimal(20,3))

	FROM 
			SYS.dm_exec_procedure_stats  p 
		CROSS APPLY
			sys.dm_exec_sql_text(p.plan_handle) qt
	where OBJECT_NAME(p.object_id,p.database_id) =@ProcName;
	
