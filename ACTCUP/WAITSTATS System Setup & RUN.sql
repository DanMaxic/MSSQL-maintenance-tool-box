IF NOT  EXISTS (SELECT * FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(N'tempdb..ActCup_wait_stats') AND type in (N'U'))
	CREATE TABLE tempdb.[dbo].ActCup_wait_stats(
		[Ctime] datetime,
		[wait_type] [nvarchar](60) NOT NULL,
		[waiting_tasks_count] [bigint] NOT NULL,
		[wait_time_ms] [bigint] NOT NULL,
		[max_wait_time_ms] [bigint] NOT NULL,
		[signal_wait_time_ms] [bigint] NOT NULL
	) ON [PRIMARY]	
		
IF NOT  EXISTS (SELECT * FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(N'tempdb..ActCup_wait_stats_SPOTTABLE') AND type in (N'U'))
	CREATE TABLE tempdb.[dbo].[ActCup_wait_stats_SPOTTABLE](
		[wait_type] [nvarchar](60) NOT NULL,
		[waiting_tasks_count] [bigint] NOT NULL,
		[wait_time_ms] [bigint] NOT NULL,
		[max_wait_time_ms] [bigint] NOT NULL,
		[signal_wait_time_ms] [bigint] NOT NULL
	) ;	

CREATE Table #ActCup_wait_stats_TMP(
		[action] nvarchar(10),
		[Ctime] datetime,
		[wait_type] [nvarchar](60) NOT NULL,
		[waiting_tasks_count] [bigint] NOT NULL,
		[wait_time_ms] [bigint] NOT NULL,
		[max_wait_time_ms] [bigint] NOT NULL,
		[signal_wait_time_ms] [bigint] NOT NULL
	);
	
	INSERT INTO #ActCup_wait_stats_TMP EXEC ('
Merge tempdb.[dbo].[ActCup_wait_stats_SPOTTABLE] AS TARGET
USING (SELECT
		[wait_type]
      ,[waiting_tasks_count]
      ,[wait_time_ms]
      ,[max_wait_time_ms]
      ,[signal_wait_time_ms]
	FROM sys.dm_os_wait_stats
	WHERE [wait_type] NOT IN (
		N''CLR_SEMAPHORE'',    N''LAZYWRITER_SLEEP'',
		N''RESOURCE_QUEUE'',   N''SQLTRACE_BUFFER_FLUSH'',
		N''SLEEP_TASK'',       N''SLEEP_SYSTEMTASK'',
		N''WAITFOR'',          N''HADR_FILESTREAM_IOMGR_IOCOMPLETION'',
		N''CHECKPOINT_QUEUE'', N''REQUEST_FOR_DEADLOCK_SEARCH'',
		N''XE_TIMER_EVENT'',   N''XE_DISPATCHER_JOIN'',
		N''LOGMGR_QUEUE'',     N''FT_IFTS_SCHEDULER_IDLE_WAIT'',
		N''BROKER_TASK_STOP'', N''CLR_MANUAL_EVENT'',
		N''CLR_AUTO_EVENT'',   N''DISPATCHER_QUEUE_SEMAPHORE'',
		N''TRACEWRITE'',       N''XE_DISPATCHER_WAIT'',
		N''BROKER_TO_FLUSH'',  N''BROKER_EVENTHANDLER'',
		N''FT_IFTSHC_MUTEX'',  N''SQLTRACE_INCREMENTAL_FLUSH_SLEEP'',
		N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')) 
AS Source
ON (Target.[wait_type] =Source.[wait_type])
WHEN MATCHED 
	THEN UPDATE SET 
					Target.[waiting_tasks_count] =Source.[waiting_tasks_count]
					,Target.[wait_time_ms] =Source.[wait_time_ms]
					,Target.[max_wait_time_ms] =Source.[max_wait_time_ms]
					,Target.[signal_wait_time_ms] =Source.[signal_wait_time_ms]
WHEN NOT MATCHED
		THEN INSERT	(		[wait_type]
						  ,[waiting_tasks_count]
						  ,[wait_time_ms]
						  ,[max_wait_time_ms]
						  ,[signal_wait_time_ms])
		VALUES	(	Source.[wait_type]
					,Source.[waiting_tasks_count]
					,Source.[wait_time_ms]
					,Source.[max_wait_time_ms]
					,Source.[signal_wait_time_ms])

OUTPUT 
		$action		as [action]
		,GetDate()	as [Ctime]
		,Inserted.[wait_type]
		,Inserted.[waiting_tasks_count] - isnull(deleted.[waiting_tasks_count],0)		as [waiting_tasks_count]
		,Inserted.[wait_time_ms] - isnull(deleted.[wait_time_ms],0)						as [wait_time_ms]
		,Inserted.[max_wait_time_ms] - isnull(deleted.[max_wait_time_ms],0)				as [max_wait_time_ms]
		,Inserted.[signal_wait_time_ms] - isnull(deleted.[signal_wait_time_ms],0)		as [signal_wait_time_ms]
		;');
INSERT INTO tempdb..ActCup_wait_stats ([Ctime]
           ,[wait_type]
           ,[waiting_tasks_count]
           ,[wait_time_ms]
           ,[max_wait_time_ms]
           ,[signal_wait_time_ms])
select		[Ctime]
           ,[wait_type]
           ,[waiting_tasks_count]
           ,[wait_time_ms]
           ,[max_wait_time_ms]
           ,[signal_wait_time_ms] 
from #ActCup_wait_stats_TMP
where action <> 'insert';
drop table #ActCup_wait_stats_TMP;