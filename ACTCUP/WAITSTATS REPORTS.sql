
/*
<====================================DYNAMIC REPORT FOR WAIT STATS ON THE SYSTEM ==================================>
BUILD 18/08/2014, (c) Daniel Maxic

Aviable Reports:
Show All Aviable Reports

ALL WAITS Presentage report ON THE SYSTEM SINCE SETUP

ALL WAITS LAST 1H (by wait_time_ms)
ALL WAITS LAST 12H (by wait_time_ms)
ALL WAITS LAST 24H (by wait_time_ms)
ALL WAITS ON THE SYSTEM SINCE SETUP (by wait_time_ms)


*/


/*<================REPORT SETTINGS==============>*/
Declare @input_string nvarchar(1024)='ALL WAITS ON THE SYSTEM SINCE SETUP By Predefined hours';
DECLARE @MINDATE datetime=(Getdate()-1);
DECLARE @MAXDATE datetime=(Getdate());

/*<================END REPORT SETTINGS==============>*/

Declare @Reports	table([Report Name] Nvarchar(100),[GetIt] bit	Default(0),[ShowIt] bit	Default(0),[CODETORUN] Nvarchar(max));  
/*Pivot relevant columns */
Declare @DynamicPivotReport_WaitTypes Nvarchar(max)='';
select @DynamicPivotReport_WaitTypes=@DynamicPivotReport_WaitTypes +('['+wait_type + '],')
		  FROM [tempdb].[dbo].[ActCup_wait_stats]
		  group by [wait_type] having SUM([waiting_tasks_count]) <>0;
set @DynamicPivotReport_WaitTypes =LEFT(@DynamicPivotReport_WaitTypes, LEN(@DynamicPivotReport_WaitTypes) - 1);


/*REPORTS CODES*/

/*PRESENTAGE REPORT*/
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS Presentage report ON THE SYSTEM SINCE SETUP'
														,'WITH HistoricalWaits AS(SELECT
																					[wait_type],
																					SUM([wait_time_ms]) AS [wait_time_ms],
																					SUM([wait_time_ms]) AS [signal_wait_time_ms],
																					SUM([waiting_tasks_count]) AS [waiting_tasks_count]
																				FROM tempdb.dbo.ActCup_wait_stats
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
																					N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')
																				GROUP BY [wait_type])
															,[Waits] AS
																(SELECT
																	[wait_type],
																	([wait_time_ms]) / 1000.0 AS [WaitS],
																	([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
																	([signal_wait_time_ms]) / 1000.0 AS [SignalS],
																	([waiting_tasks_count]) AS [WaitCount],
																	100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
																	ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]	
																	FROM HistoricalWaits)
														SELECT
															[W1].[wait_type] AS [WaitType], 
															CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
															CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
															CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
															[W1].[WaitCount] AS [WaitCount],
															CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
															CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
															CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
															CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
														FROM [Waits] AS [W1]
														INNER JOIN [Waits] AS [W2]
															ON [W2].[RowNum] <= [W1].[RowNum]
														GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
															[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
														HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 99;
															');	
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS Presentage report Last 1 hour'
														,'WITH HistoricalWaits AS(SELECT
																					[wait_type],
																					SUM([wait_time_ms]) AS [wait_time_ms],
																					SUM([wait_time_ms]) AS [signal_wait_time_ms],
																					SUM([waiting_tasks_count]) AS [waiting_tasks_count]
																				FROM tempdb.dbo.ActCup_wait_stats
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
																					N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')
																				AND  Ctime between (DATEADD(HH,-1,GETDATE())) AND GETDATE()
																				GROUP BY [wait_type])
															,[Waits] AS
																(SELECT
																	[wait_type],
																	([wait_time_ms]) / 1000.0 AS [WaitS],
																	([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
																	([signal_wait_time_ms]) / 1000.0 AS [SignalS],
																	([waiting_tasks_count]) AS [WaitCount],
																	100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
																	ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]	
																	FROM HistoricalWaits)
														SELECT
															[W1].[wait_type] AS [WaitType], 
															CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
															CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
															CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
															[W1].[WaitCount] AS [WaitCount],
															CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
															CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
															CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
															CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
														FROM [Waits] AS [W1]
														INNER JOIN [Waits] AS [W2]
															ON [W2].[RowNum] <= [W1].[RowNum]
														GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
															[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
														HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 99;
															');																
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS Presentage report Last 12 hours'
														,'WITH HistoricalWaits AS(SELECT
																					[wait_type],
																					SUM([wait_time_ms]) AS [wait_time_ms],
																					SUM([wait_time_ms]) AS [signal_wait_time_ms],
																					SUM([waiting_tasks_count]) AS [waiting_tasks_count]
																				FROM tempdb.dbo.ActCup_wait_stats
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
																					N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')
																				AND  Ctime between (DATEADD(HH,-12,GETDATE())) AND GETDATE()
																				GROUP BY [wait_type])
															,[Waits] AS
																(SELECT
																	[wait_type],
																	([wait_time_ms]) / 1000.0 AS [WaitS],
																	([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
																	([signal_wait_time_ms]) / 1000.0 AS [SignalS],
																	([waiting_tasks_count]) AS [WaitCount],
																	100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
																	ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]	
																	FROM HistoricalWaits)
														SELECT
															[W1].[wait_type] AS [WaitType], 
															CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
															CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
															CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
															[W1].[WaitCount] AS [WaitCount],
															CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
															CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
															CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
															CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
														FROM [Waits] AS [W1]
														INNER JOIN [Waits] AS [W2]
															ON [W2].[RowNum] <= [W1].[RowNum]
														GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
															[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
														HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 99;
															');																
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS Presentage report Last 24 hours'
														,'WITH HistoricalWaits AS(SELECT
																					[wait_type],
																					SUM([wait_time_ms]) AS [wait_time_ms],
																					SUM([wait_time_ms]) AS [signal_wait_time_ms],
																					SUM([waiting_tasks_count]) AS [waiting_tasks_count]
																				FROM tempdb.dbo.ActCup_wait_stats
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
																					N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')
																				AND  Ctime between (DATEADD(HH,-24,GETDATE())) AND GETDATE()
																				GROUP BY [wait_type])
															,[Waits] AS
																(SELECT
																	[wait_type],
																	([wait_time_ms]) / 1000.0 AS [WaitS],
																	([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
																	([signal_wait_time_ms]) / 1000.0 AS [SignalS],
																	([waiting_tasks_count]) AS [WaitCount],
																	100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
																	ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]	
																	FROM HistoricalWaits)
														SELECT
															[W1].[wait_type] AS [WaitType], 
															CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
															CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
															CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
															[W1].[WaitCount] AS [WaitCount],
															CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
															CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
															CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
															CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
														FROM [Waits] AS [W1]
														INNER JOIN [Waits] AS [W2]
															ON [W2].[RowNum] <= [W1].[RowNum]
														GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
															[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
														HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 99;
															');																
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS Presentage report By Predefined hours'
														,'WITH HistoricalWaits AS(SELECT
																					[wait_type],
																					SUM([wait_time_ms]) AS [wait_time_ms],
																					SUM([wait_time_ms]) AS [signal_wait_time_ms],
																					SUM([waiting_tasks_count]) AS [waiting_tasks_count]
																				FROM tempdb.dbo.ActCup_wait_stats
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
																					N''DIRTY_PAGE_POLL'',	 N''BROKER_RECEIVE_WAITFOR'')
																				AND  Ctime between (cast('''+CONVERT(nvarchar(50),@MINDATE,120)+''' as datetime)) AND (cast('''+CONVERT(nvarchar(50),@MAXDATE,120)+''' as datetime))
																				GROUP BY [wait_type])
															,[Waits] AS
																(SELECT
																	[wait_type],
																	([wait_time_ms]) / 1000.0 AS [WaitS],
																	([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
																	([signal_wait_time_ms]) / 1000.0 AS [SignalS],
																	([waiting_tasks_count]) AS [WaitCount],
																	100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
																	ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]	
																	FROM HistoricalWaits)
														SELECT
															[W1].[wait_type] AS [WaitType], 
															CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
															CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
															CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
															[W1].[WaitCount] AS [WaitCount],
															CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
															CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
															CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
															CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
														FROM [Waits] AS [W1]
														INNER JOIN [Waits] AS [W2]
															ON [W2].[RowNum] <= [W1].[RowNum]
														GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
															[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
														HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 99;
															');																

insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS LAST 1H (by wait_time_ms)'
														,'select [Ctime] as CaptureDate ,'+@DynamicPivotReport_WaitTypes+'
															FROM
																(SELECT	[Ctime],[wait_type],	(wait_time_ms) as wait_time_ms
																	from [tempdb].[dbo].[ActCup_wait_stats] 
																	where [wait_type] in (
																  select [wait_type]
																  FROM [tempdb].[dbo].[ActCup_wait_stats]
																  group by [wait_type] having SUM([waiting_tasks_count]) <>0)
																  AND Ctime between (DATEADD(HH,-1,GETDATE())) AND GETDATE()
																)  AS SourceTable
															PIVOT 
															(
																SUM(wait_time_ms)
																FOR [wait_type] in ('+@DynamicPivotReport_WaitTypes+')
															) AS PivotTable order by 1 asc;
															');
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS LAST 12H (by wait_time_ms)'
														,'select [Ctime] as CaptureDate ,'+@DynamicPivotReport_WaitTypes+'
															FROM
																(SELECT	[Ctime],[wait_type],	(wait_time_ms) as wait_time_ms
																	from [tempdb].[dbo].[ActCup_wait_stats] 
																	where [wait_type] in (
																  select [wait_type]
																  FROM [tempdb].[dbo].[ActCup_wait_stats]
																  group by [wait_type] having SUM([waiting_tasks_count]) <>0)
																  AND Ctime between (DATEADD(HH,-12,GETDATE())) AND GETDATE()
																)  AS SourceTable
															PIVOT 
															(
																SUM(wait_time_ms)
																FOR [wait_type] in ('+@DynamicPivotReport_WaitTypes+')
															) AS PivotTable order by 1 asc;
															');
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS LAST 24H (by wait_time_ms)'
														,'select [Ctime] as CaptureDate ,'+@DynamicPivotReport_WaitTypes+'
															FROM
																(SELECT	[Ctime],[wait_type],	(wait_time_ms) as wait_time_ms
																	from [tempdb].[dbo].[ActCup_wait_stats] 
																	where [wait_type] in (
																  select [wait_type]
																  FROM [tempdb].[dbo].[ActCup_wait_stats]
																  group by [wait_type] having SUM([waiting_tasks_count]) <>0)
																  AND Ctime between (GETDATE()-1) AND GETDATE()
																)  AS SourceTable
															PIVOT 
															(
																SUM(wait_time_ms)
																FOR [wait_type] in ('+@DynamicPivotReport_WaitTypes+')
															) AS PivotTable order by 1 asc;
															');
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS ON THE SYSTEM SINCE SETUP (by wait_time_ms)'
														,'select [Ctime] as CaptureDate ,'+@DynamicPivotReport_WaitTypes+'
															FROM
																(SELECT	[Ctime],[wait_type],	(wait_time_ms) as wait_time_ms
																	from [tempdb].[dbo].[ActCup_wait_stats] 
																	where [wait_type] in (
																  select [wait_type]
																  FROM [tempdb].[dbo].[ActCup_wait_stats]
																  group by [wait_type] having SUM([waiting_tasks_count]) <>0)
																)  AS SourceTable
															PIVOT 
															(
																SUM(wait_time_ms)
																FOR [wait_type] in ('+@DynamicPivotReport_WaitTypes+')
															) AS PivotTable order by 1 asc;
															');	
insert into @Reports ([Report Name],[CODETORUN])values ('ALL WAITS ON THE SYSTEM SINCE SETUP By Predefined hours'
														,'select [Ctime] as CaptureDate ,'+@DynamicPivotReport_WaitTypes+'
															FROM
																(SELECT	[Ctime],[wait_type],	(wait_time_ms) as wait_time_ms
																	from [tempdb].[dbo].[ActCup_wait_stats] 
																	where [wait_type] in (
																  select [wait_type]
																  FROM [tempdb].[dbo].[ActCup_wait_stats]
																  group by [wait_type] having SUM([waiting_tasks_count]) <>0)
																  AND  Ctime between (cast('''+CONVERT(nvarchar(50),@MINDATE,120)+''' as datetime)) AND (cast('''+CONVERT(nvarchar(50),@MAXDATE,120)+''' as datetime))
																)  AS SourceTable
															PIVOT 
															(
																SUM(wait_time_ms)
																FOR [wait_type] in ('+@DynamicPivotReport_WaitTypes+')
															) AS PivotTable order by 1 asc;
															');	
		
															
IF (@input_string is null or @input_string ='')
BEGIN				
	SELECT 'NO VALID REPORT ENTERED ON THE SCRIPT HEADER';												
	select [Report Name] AS '<==AVIABLE REPORTS==>'from @Reports;
	return;
END														
ELSE BEGIN
	IF (EXISTS(SELECT 1 FROM @Reports where [Report Name] LIKE @input_string ))
	BEGIN
		SELECT 'COPY RESULTS TO EXCEL TO SEE GRAPHS';
		DECLARE @DynamicCode NVARCHAR(max) = '';
		select @DynamicCode =[CODETORUN] FROM @Reports where [Report Name] LIKE @input_string;
		--print @DynamicCode;
		exec (@DynamicCode);
	END
	ELSE BEGIN
		SELECT 'NO VALID REPORT ENTERED ON THE SCRIPT HEADER';
		select [Report Name] AS '<==AVIABLE REPORTS==>'from @Reports;
		return;
	END
END
