

-- Run the first part of RunAQuery.sql
-- Get session number of window with RunAQuery.sql in it
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

-- Create the event session
CREATE EVENT SESSION [MonitorWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
	(
		ACTION(  
			sqlserver.database_id,  
			sqlserver.session_id,  
			sqlserver.sql_text,  
			sqlserver.plan_handle  
			)
		WHERE [sqlserver].[session_id] = 951 /*session_id of window 2*/)
ADD TARGET [package0].[asynchronous_file_target]
    (SET FILENAME = N'B:\DBA_Share\EE_WaitStats.xel', 
    METADATAFILE = N'B:\DBA_Share\EE_WaitStats.xem')
WITH (max_dispatch_latency = 1 seconds);
GO

-- Start the session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = START;
GO

-- Go do the query

-- Stop the event session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = STOP;
GO

-- Do we have any rows yet?
SELECT COUNT (*)
	FROM sys.fn_xe_file_target_read_file (
	'B:\DBA_Share\EE_WaitStats*.xel',
	'B:\DBA_Share\EE_WaitStats*.xem',
	null, null);
GO


--Anal
;WITH MyXEventData AS (  
SELECT   
DATEADD(hh,   
DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP),   
XEventData.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],  
COALESCE(XEventData.value('(event/data[@name="database_id"]/value)[1]', 'int'),   
XEventData.value('(event/action[@name="database_id"]/value)[1]', 'int')) AS database_id,  
XEventData.value('(event/action[@name="session_id"]/value)[1]', 'int') AS [session_id],  
XEventData.value('(event/data[@name="wait_type"]/text)[1]', 'nvarchar(4000)') AS [wait_type],  
XEventData.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS [duration],  
XEventData.value('(event/action[@name="plan_handle"]/value)[1]', 'nvarchar(4000)') AS [plan_handle],  
XEventData.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(4000)') AS [sql_text]  
FROM (  
    SELECT CAST (event_data AS XML) AS XEventData  
    FROM sys.fn_xe_file_target_read_file (  
        'B:\DBA_Share\EE_WaitStats*.xel',
	'B:\DBA_Share\EE_WaitStats*.xem', null, null)) RawData  
)  
SELECT [session_id],database_id,[wait_type],[sql_text],sum([duration])/1000
   FROM MyXEventData
group by [session_id],database_id,[wait_type],[sql_text]
  


-- Create intermediate temp table for raw event data
CREATE TABLE [##RawEventData] (
	[Rowid]			INT IDENTITY PRIMARY KEY,
	[event_data]	XML);
GO

-- Read the file data into intermediate temp table
INSERT INTO [##RawEventData] ([event_data])
SELECT
    CAST ([event_data] AS XML) AS [event_data]
FROM sys.fn_xe_file_target_read_file (
	'C:\XTRACE\EE_WaitStats*.xel',
	'C:\XTRACE\EE_WaitStats*.xem',
	null, null);
GO

-- And now extract everything nicely
SELECT
	[event_data].[value] (
		'(/event/@timestamp)[1]',
			'DATETIME') AS [Time],
	[event_data].[value] (
		'(/event/data[@name=''wait_type'']/text)[1]',
			'VARCHAR(100)') AS [Wait Type],
	[event_data].[value] (
		'(/event/data[@name=''opcode'']/text)[1]',
			'VARCHAR(100)') AS [Op],
	[event_data].[value] (
		'(/event/data[@name=''duration'']/value)[1]',
			'BIGINT') AS [Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''max_duration'']/value)[1]',
			'BIGINT') AS [Max Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''total_duration'']/value)[1]',
			'BIGINT') AS [Total Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''signal_duration'']/value)[1]',
			'BIGINT') AS [Signal Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''completed_count'']/value)[1]',
			'BIGINT') AS [Count]
FROM [##RawEventData];
GO

-- And finally, aggregation
SELECT
	[waits].[Wait Type],
	COUNT (*) AS [Wait Count],
	SUM ([waits].[Duration]) AS [Total Wait Time (ms)],
	SUM ([waits].[Duration]) - SUM ([waits].[Signal Duration])
		AS [Total Resource Wait Time (ms)],
	SUM ([waits].[Signal Duration]) AS [Total Signal Wait Time (ms)]
FROM 
	(SELECT
		[event_data].[value] (
			'(/event/@timestamp)[1]',
				'DATETIME') AS [Time],
		[event_data].[value] (
			'(/event/data[@name=''wait_type'']/text)[1]',
				'VARCHAR(100)') AS [Wait Type],
		[event_data].[value] (
			'(/event/data[@name=''opcode'']/text)[1]',
				'VARCHAR(100)') AS [Op],
		[event_data].[value] (
			'(/event/data[@name=''duration'']/value)[1]',
				'BIGINT') AS [Duration],
		[event_data].[value] (
			'(/event/data[@name=''signal_duration'']/value)[1]',
				'BIGINT') AS [Signal Duration]
	FROM [##RawEventData]
	) AS [waits]
WHERE [waits].[op] = 'End'
GROUP BY [waits].[Wait Type]
ORDER BY [Total Wait Time (ms)] DESC;
GO

-- Cleanup
DROP TABLE [##RawEventData];
GO

IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO
