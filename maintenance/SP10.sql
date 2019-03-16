


SET NOCOUNT ON ;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;



DECLARE @MODE TABLE  
      (
            [ALL]                   BIT DEFAULT (0), 
            WAIT                    BIT DEFAULT (0),
            SUSPENDED               BIT DEFAULT (1),
            CPU                           BIT DEFAULT (0), 
            BLOCKING                BIT DEFAULT (1),
            OPENTRANSACTION         BIT DEFAULT (0),
            TEMPDB                        BIT DEFAULT (0),
            TABLE_SIZE              BIT DEFAULT (0),
            CONFIG                        BIT DEFAULT (0),
            LATENCY                       BIT DEFAULT (0),
            [REPLICATION]           BIT DEFAULT (0),
            [REPLICATION ERROR]     BIT DEFAULT (0)
      )

INSERT INTO @MODE DEFAULT VALUES
SELECT * FROM @MODE


IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR WAIT = 1)
BEGIN
select '***************Server Wait Statistics*****************' as QueryMode
/*
A thread is using the CPU (called RUNNING) until it needs to wait for a resource. 
It then moves to an unordered list of threads that are SUSPENDED. 
In the meantime, the next thread on the FIFO (first-in-first-out) queue of threads waiting for the CPU (called being RUNNABLE) 
is given the CPU and becomes RUNNING. 
If a thread on the SUSPENDED list is notified that it's resource is available, 
it becomes RUNNABLE and is put on the bottom of the RUNNABLE queue. 
Threads continue this clockwise movement from RUNNING to SUSPENDED to RUNNABLE to RUNNING again until the task is completed. 
You can see processes in these states using the sys.dm_exec_requests DMV.  

SQL Server keeps track of the time that elapses between leaving the RUNNING state and becoming RUNNING again (called the "wait time") 
and the time spent on the RUNNABLE queue (called the "signal wait time" - i.e. how long does the thread need to wait for the 
CPU after being signaled that its resource is available). 
We need to work out the time spent waiting on the SUSPENDED list (called the "resource wait time") 
by subtracting the signal wait time from the overall wait time. 

•505: CXPACKET 
 This is commonly where a query is parallelized and the parallel threads are not given equal amounts of work to do, or one thread blocks. 
 One thread may have a lot more to do than the others, and so the whole query is blocked while the long-running thread completes. 
 If this is combined with a high number of PAGEIOLATCH_XX waits, 
 it could be large parallel table scans going on because of incorrect non-clustered indexes,
or out-of-date statistics causing a bad query plan. If neither of these are the issue, 
 you might want to try setting MAXDOP to 4, 2, or 1 for the offending queries (or possibly the whole instance).
Make sure that if you have a NUMA system that you try setting MAXDOP to the number of cores in a single NUMA node first 
 to see if that helps the problem. You also need to consider the MAXDOP effect on a mixed-load system.
•304: PAGEIOLATCH_XX 
 This is where SQL Server is waiting for a data page to be read from disk into memory. 
 It commonly indicates a bottleneck at the IO subsystem level, 
 but could also indicate buffer pool pressure (i.e. not enough memory for the workload).
•275: ASYNC_NETWORK_IO 
 This is commonly where SQL Server is waiting for a client to finish consuming data. 
 It could be that the client has asked for a very large amount of data or just that it's consuming it reeeeeally slowly 
 because of poor programming.
•112: WRITELOG 
 This is the log management system waiting for a log flush to disk. 
 It commonly indicates a problem with the IO subsystem where the log is, 
 but on very high-volume systems it could also be caused by waiting for the LOGCACHE_ACCESS spinlock (which you can't do anything about). 
 To be sure it's the IO subsystem, use the DMV sys.dm_io_virtual_file_stats to examine the IO latency for the log file. 
•109: BROKER_RECEIVE_WAITFOR 
 This is just Service Broker waiting around for new messages to receive. 
 I would add this to the list of waits to filter out and re-run the wait stats query.  
•086: MSQL_XP 
 This is SQL Server waiting for an extended stored-proc to finish. This could indicate a problem in your XP code.  
•074: OLEDB 
 As its name suggests, this is a wait for something communicating using OLEDB 
 - e.g. a linked server. It could be that the linked server has a performance issue. 
•054: BACKUPIO 
 This shows up when you're backing up directly to tape, which is slooooow. I'd be tempted to filter this out. 
•041: LCK_M_XX 
 This is simply the thread waiting for a lock to be granted and indicates blocking problems. 
 These could be caused by unwanted lock escalation or bad programming, 
 but could also be from IOs taking a long time causing locks to be held for longer than usual. 
 Look at the resource associated with the lock using the DMV sys.dm_os_waiting_tasks. 
•032: ONDEMAND_TASK_QUEUE 
 This is normal and is part of the background task system (e.g. deferred drop, ghost cleanup).  
 I would add this to the list of waits to filter out and re-run the wait stats query. 
•031: BACKUPBUFFER 
 This shows up when you're backing up directly to tape, which is slooooow. 
 I'd be tempted to filter this out. 
•027: IO_COMPLETION 
 This is SQL Server waiting for IOs to complete and is a sure indication of IO subsystem problems. 
•024: SOS_SCHEDULER_YIELD 
 If this is a very high percentage of all waits (had to say, but Joe suggests 80%) then this is likely indicative of CPU pressure. 
•022: DBMIRROR_EVENTS_QUEUE 
•022: DBMIRRORING_CMD 
 These two are database mirroring just sitting around waiting for something to do. 
 I would add these to the list of waits to filter out and re-run the wait stats query. 
•018: PAGELATCH_XX 
 This is contention for access to in-memory copies of pages. 
 The most well-known cases of these are the PFS, SGAM, and GAM contention that can occur in tempdb under certain workloads. 
 To find out what page the contention is on, you'll need to use the DMV sys.dm_os_waiting_tasks to figure out what page the latch is for.
For tempdb issues, my friend Robert Davis (blog|twitter) has a good post showing how to do this. 
 Another common cause I've seen is an index hot-spot with concurrent inserts into an index with an identity value key.
•016: LATCH_XX 
 This is contention for some non-page structure inside SQL Server - so not related to IO or data at all. 
 These can be hard to figure out and you're going to be using the DMV sys.dm_os_latch_stats. 
 More on this in future posts.
•013: PREEMPTIVE_OS_PIPEOPS 
 This is SQL Server switching to pre-emptive scheduling mode to call out to Windows for something. 
 These were added for 2008 and haven't been documented yet (anywhere) so I don't know exactly what it means. 
•013: THREADPOOL 
 This says that there aren't enough worker threads on the system to satisfy demand. 
 You might consider raising the max worker threads setting. 
•009: BROKER_TRANSMITTER 
 This is just Service Broker waiting around for new messages to send. 
 I would add this to the list of waits to filter out and re-run the wait stats query.  
•006: SQLTRACE_WAIT_ENTRIES 
 Part of SQL Trace. 
 I would add this to the list of waits to filter out and re-run the wait stats query. 
•005: DBMIRROR_DBM_MUTEX 
 This one is undocumented and is contention for the send buffer that database mirroring 
 shares between all the mirroring sessions on a server. It could indicate that you've got too many mirroring sessions. 
•005: RESOURCE_SEMAPHORE 
 This is queries waiting for execution memory (the memory used to process the query operators - like a sort). 
 This could be memory pressure or a very high concurrent workload.  
•003: PREEMPTIVE_OS_AUTHENTICATIONOPS 
•003: PREEMPTIVE_OS_GENERICOPS 
 These are SQL Server switching to pre-emptive scheduling mode to call out to Windows for something. 
 These were added for 2008 and haven't been documented yet (anywhere) so I don't know exactly what it means. 
•003: SLEEP_BPOOL_FLUSH 
 This is normal to see and indicates that checkpoint is throttling itself to avoid overloading the IO subsystem. 
 I would add this to the list of waits to filter out and re-run the wait stats query. 
•002: MSQL_DQ 
 This is SQL Server waiting for a distributed query to finish. 
 This could indicate a problem with the distributed query, or it could just be normal. 
•002: RESOURCE_SEMAPHORE_QUERY_COMPILE 
 When there are too many concurrent query compilations going on, SQL Server will throttle them. 
 I don't remember the threshold, but this can indicate excessive recompilation, or maybe single-use plans. 
•001: DAC_INIT 
 I've never seen this one before and BOL says it's because the dedicated admin connection is initializing. 
 I can't see how this is the most common wait on someone's system...  
•001: MSSEARCH 
 This is normal to see for full-text operations.  
 If this is the highest wait, it could mean your system is spending most of its time doing full-text queries. 
 You might want to consider adding this to the filter list.  
•001: PREEMPTIVE_OS_FILEOPS 
•001: PREEMPTIVE_OS_LIBRARYOPS 
•001: PREEMPTIVE_OS_LOOKUPACCOUNTSID 
•001: PREEMPTIVE_OS_QUERYREGISTRY 
 These are SQL Server switching to pre-emptive scheduling mode to call out to Windows for something. 
 These were added for 2008 and haven't been documented yet (anywhere) so I don't know exactly what it means.  
•001: SQLTRACE_LOCK 
 Part of SQL Trace. I would add this to the list of waits to filter out and re-run the wait stats query. 

*/
;WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
        'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
        'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK')
    )
SELECT
    W1.wait_type AS WaitType, 
    CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
    CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
    CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
    W1.WaitCount AS WaitCount,
    CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage,
    CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgWait_S,
    CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgRes_S,
    CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgSig_S
FROM Waits AS W1
    INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold

select '***************CONTENTION ON PFS (In Page), GAM (Extent), SGAM (Extent) *****************' as QueryMode

select 
            resource_description 
from 
            sys.dm_os_waiting_tasks 
where 
            resource_description like ('%:1:1') 
            or 
            resource_description like ('%:1:2')
            or
            resource_description like ('%:1:3')

END


IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR LATENCY = 1)
BEGIN
select '***************Latency on DB files***************' as QueryMode
/*
      Databse Data Files
            - Target:         < 10 ms
            - Acceptable:     10 - 20 ms
            - unacceptable: > 20 ms
      Databse Log Files
            - Target:         < 5 ms
            - Acceptable:     5 - 15 ms
            - unacceptable: > 15 ms
*/
select      
      DB_NAME(f.database_id) as DBNAME,
      f.file_id,
      --num_of_reads,
      --num_of_writes,
      --io_stall_read_ms,
      --io_stall_write_ms,
      size_on_disk_bytes/1000/1000 as size_on_disk_mb,
      io_stall/1000/60 [users waited for I/O to be completed in min],
      io_stall_read_ms / num_of_reads as [Avg Read Transfer /Ms], 
      io_stall_write_ms / num_of_writes as [Avg Write Transfer /Ms],
      type_desc as [File Type Desc],
      physical_name
from 
      sys.master_files s 
            inner join
      sys.dm_io_virtual_file_stats(null,null) f on s.database_id=f.database_id and s.file_id=f.file_id
where
      num_of_reads>0
            and
      num_of_writes > 0
--          and
      --DB_NAME(f.database_id) in ('FXMD' , 'Tempdb', 'RMResult', 'RM')
order by 
      io_stall desc

END

IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR BLOCKING = 1)
BEGIN
select '***************Who is in BLOCKING***************' as QueryMode
select spid, blocked, waittype
    , waittime, lastwaittype, dbid
    , uid, cpu, physical_io, memusage
    , login_time, last_batch, hostname
    , program_name, nt_domain, nt_username, loginame 
 from master..sysprocesses
where blocked <> 0 
 or spid in (select blocked from master..sysprocesses)
order by 2 asc
END


IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR OPENTRANSACTION = 1)
BEGIN
select '***************Which Transaction is open and How much Log Size it catch***************' as QueryMode
SELECT s_tst.[session_id],
   s_es.[login_name] AS [Login Name],
   DB_NAME (s_tdt.database_id) AS [Database],
   s_tdt.[database_transaction_begin_time] AS [Begin Time],
   s_tdt.[database_transaction_log_record_count] AS [Log Records],
   s_tdt.[database_transaction_log_bytes_used]/1024/1024 AS [Log MBytes],
   s_tdt.[database_transaction_log_bytes_reserved]/1024/1024 AS [Log MBRsvd],
   s_est.[text] AS [Last T-SQL Text],
   s_eqp.[query_plan] AS [Last Plan]
FROM sys.dm_tran_database_transactions s_tdt
   JOIN sys.dm_tran_session_transactions s_tst
      ON s_tst.[transaction_id] = s_tdt.[transaction_id]
   JOIN sys.[dm_exec_sessions] s_es
      ON s_es.[session_id] = s_tst.[session_id]
   JOIN sys.dm_exec_connections s_ec
      ON s_ec.[session_id] = s_tst.[session_id]
   LEFT OUTER JOIN sys.dm_exec_requests s_er
      ON s_er.[session_id] = s_tst.[session_id]
   CROSS APPLY sys.dm_exec_sql_text (s_ec.[most_recent_sql_handle]) AS s_est
   OUTER APPLY sys.dm_exec_query_plan (s_er.[plan_handle]) AS s_eqp
   where s_tdt.[database_transaction_log_bytes_reserved]/1024 > 100
ORDER BY [Begin Time] ASC;
END

IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR SUSPENDED = 1)
BEGIN
select '***************Who is in Suspended, Runnable and Running Mode***************' as QueryMode
;with cte as
(
      select
            R.[session_id],[blocking_session_id],R.[status],[wait_type],[command],[wait_time],[Program_Name],[request_id],[start_time],[statement_start_offset],[statement_end_offset],[plan_handle],[database_id],[user_id],[connection_id],[last_wait_type],[wait_resource],[open_transaction_count],[open_resultset_count],[transaction_id],R.[context_info],[percent_complete],[estimated_completion_time],R.[cpu_time],R.[total_elapsed_time],[scheduler_id],[task_address],R.[reads],R.[writes],R.[logical_reads],R.[text_size],R.[language],R.[date_format],R.[date_first],R.[quoted_identifier],R.[arithabort],R.[ansi_null_dflt_on],R.[transaction_isolation_level],R.[lock_timeout],R.[deadlock_priority],R.[row_count],R.[prev_error],[nest_level],[granted_query_memory],[executing_managed_code],[login_time],[host_name],[host_process_id],[client_version],[client_interface_name],[security_id],[login_name],[nt_domain],[nt_user_name], [memory_usage],[total_scheduled_time], [endpoint_id],[last_request_start_time],[last_request_end_time], [is_user_process], [original_security_id],[original_login_name],[last_successful_logon],[last_unsuccessful_logon],[unsuccessful_logons],R.sql_handle


      from 
            sys.dm_exec_requests R 
                  Left Join 
            sys.dm_Exec_Sessions S On R.Session_Id=S.Session_id 
      where 
            R.status in ('SUSPENDED', 'RUNNABLE' , 'RUNNING')
            and
            s.session_id<>@@SPID

      Union

      --Select STop.session_id,Program_Name,wait_type,blocking_session_id,* 
      select 
      R.[session_id],[blocking_session_id],R.[status],[wait_type],[command],[wait_time],[Program_Name],[request_id],[start_time],[statement_start_offset],[statement_end_offset],[plan_handle],[database_id],[user_id],[connection_id],[last_wait_type],[wait_resource],[open_transaction_count],[open_resultset_count],[transaction_id],R.[context_info],[percent_complete],[estimated_completion_time],R.[cpu_time],R.[total_elapsed_time],[scheduler_id],[task_address],R.[reads],R.[writes],R.[logical_reads],R.[text_size],R.[language],R.[date_format],R.[date_first],R.[quoted_identifier],R.[arithabort],R.[ansi_null_dflt_on],R.[transaction_isolation_level],R.[lock_timeout],R.[deadlock_priority],R.[row_count],R.[prev_error],[nest_level],[granted_query_memory],[executing_managed_code],[login_time],[host_name],[host_process_id],[client_version],[client_interface_name],[security_id],[login_name],[nt_domain],[nt_user_name], [memory_usage],[total_scheduled_time], [endpoint_id],[last_request_start_time],[last_request_end_time], [is_user_process], [original_security_id],[original_login_name],[last_successful_logon],[last_unsuccessful_logon],[unsuccessful_logons] , R.sql_handle
      from 
            sys.dm_exec_requests R 
                  Left Join 
            sys.dm_Exec_Sessions STop On R.Session_Id=STop.Session_id 
      where STop.session_id<>@@SPID and Exists (
                              Select 1 
                              from 
                                    sys.dm_exec_requests R 
                                          Left Join 
                                    sys.dm_Exec_Sessions S On R.Session_Id=S.Session_id 
                              where 
                                    R.status in ('SUSPENDED', 'RUNNABLE' , 'RUNNING') 
                                          And 
                                    Stop.Session_id = Blocking_session_id
                              )
)
select      
             SUBSTRING(e.text, (c.statement_start_offset/2)+1, 
        ((CASE c.statement_end_offset
          WHEN -1 THEN DATALENGTH(e.text)
         ELSE c.statement_end_offset
         END - c.statement_start_offset)/2) + 1) AS statement_text,
db_name(e.dbid) as DBNAME,e.text,c.* 
from cte c cross apply sys.dm_exec_sql_text(sql_handle) e
order by blocking_session_id asc
END


IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR CPU = 1)
BEGIN

select '***************Top 5 CPU query***************' as QueryMode 
If ( OBJECT_ID ( N'tempdb.dbo.#temp' ) Is Not Null )  
      Begin    
            DROP TABLE #temp;  
      End;    
select r.cpu_time 

                ,r.logical_reads

                , r.session_id 

into #temp

from sys.dm_exec_requests as r 



waitfor delay '00:00:01'



select substring(h.text, (r.statement_start_offset/2)+1 , ((case r.statement_end_offset when -1 then datalength(h.text) 



else r.statement_end_offset end - r.statement_start_offset)/2) + 1) as text, s.session_id 

                , r.cpu_time-t.cpu_time as CPUDiff 

                , r.logical_reads-t.logical_reads as ReadDiff

                , r.wait_type, r.wait_time

                , r.last_wait_type

                , r.wait_resource

                , r.command

                , r.database_id

               

                , r.granted_query_memory,r.session_id

                , r.reads

                , r.writes

                , r.row_count

                , s.[host_name]

                , s.program_name

                , s.login_name

from sys.dm_exec_sessions as s inner join sys.dm_exec_requests as r 

on s.session_id =r.session_id and s.last_request_start_time=r.start_time

left join #temp as t on t.session_id=s.session_id

CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) h

order by 3 desc

END
IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR TEMPDB = 1)
BEGIN


select '***************TempDb Objects***************' as QueryMode
     
--------------------------------------------------------
---------------------Tempdb Size Status-----------------
--------------------------------------------------------
      IF   OBJECT_ID('tempdb..#tmp') IS NULL
      BEGIN
            CREATE TABLE #tmp
                  (
                  name sysname
                  ,db_size nvarchar(13)
                  ,owner sysname
                  ,dbid smallint
                  ,created nvarchar(11)
                  ,status nvarchar(600)
                  ,compatibility_level tinyint
                  )
      END
      ELSE
            DELETE #tmp

      INSERT INTO #tmp
            EXEC sp_helpdb

      
      SELECT
            t.name, 
            t.db_size,
            A.*,
            t.status    
      FROM
            #tmp t 
                  CROSS APPLY
            (
                  SELECT 
                  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
                  FROM 
                  sys.dm_db_file_space_usage
            ) A
      WHERE 
            name='tempdb' 

      
            
--------------------------------------------------------
---------------------Tempdb File Map Status-------------
--------------------------------------------------------

      DECLARE
            @DiskSize   TABLE (Drive varchar(2) NOT NULL, [MB free] int NOT NULL)
                                    
      INSERT INTO @DiskSize(Drive, [MB free])
            EXEC master.sys.xp_fixeddrives;

      SELECT 
                  Drive, 
                  [MB Free]         as [free space in Disk MB],
                  physical_name     as [Path],
                  type_desc
      FROM 
            @DiskSize D
                  INNER JOIN
            (
                  select substring(physical_name,1,1) as dbdrive,* from sys.master_files where db_name(database_id) = 'tempdb'
            )P ON P.dbdrive = D.Drive
      ORDER BY
            [MB Free] asc
            
--------------------------------------------------------------------------------------------------
---------------------Tempdb User and Internals running by Tasks and Sessions Objects -------------
--------------------------------------------------------------------------------------------------       
            

      ;WITH all_task_usage
      AS (
            SELECT 
                  session_id, 
                  request_id,
                  SUM(internal_objects_alloc_page_count) AS task_internal_objects_alloc_page_count,
                  SUM(internal_objects_dealloc_page_count) AS task_internal_objects_dealloc_page_count,
                  SUM(user_objects_alloc_page_count   ) AS task_user_objects_alloc_page_count,
                  SUM(user_objects_dealloc_page_count) AS task_user_objects_dealloc_page_count
            FROM 
                  sys.dm_db_task_space_usage 
            GROUP BY 
                  session_id , request_id
            )
      ,
            all_session_usage 
      AS (
            SELECT 
                  R1.session_id,
                  request_id,
                  (R1.internal_objects_alloc_page_count *1.0/128 )      +      (R2.task_internal_objects_alloc_page_count *1.0/128 )AS internal_objects_alloc_MB,
                  (R1.internal_objects_dealloc_page_count *1.0/128 )    +      (R2.task_internal_objects_dealloc_page_count *1.0/128 ) AS internal_objects_dealloc_MB,
                  (R1.user_objects_alloc_page_count *1.0/128 )          +      (R2.task_user_objects_alloc_page_count *1.0/128 )AS user_objects_alloc_MB,
                  (R1.user_objects_dealloc_page_count *1.0/128 )        +      (R2.task_user_objects_dealloc_page_count *1.0/128 ) AS user_objects_dealloc_MB
            FROM 
                  sys.dm_db_session_space_usage AS R1 
                        INNER JOIN 
                  all_task_usage AS R2 ON R1.session_id = R2.session_id
            )
    
    SELECT 
            R3.text,
            R1.session_id,
            R4.program_name,
            host_name,
            R4.status,
            user_objects_alloc_MB,
            user_objects_dealloc_MB,
            user_objects_alloc_MB - user_objects_dealloc_MB as [User Object DIff],
            internal_objects_alloc_MB,
            internal_objects_dealloc_MB,
            internal_objects_alloc_MB - internal_objects_dealloc_MB as [Internal Object DIff]
    FROM 
            all_session_usage R1  
                  INNER JOIN 
            sys.dm_exec_sessions R4 ON R1.session_id = R4.session_id 
                  LEFT JOIN 
            sys.dm_exec_requests R2 ON R4.session_id = R2.session_id and R1.request_id = R2.request_id  
                  OUTER APPLY 
            sys.dm_exec_sql_text(R2.sql_handle) AS R3
    ORDER BY 
            user_objects_alloc_MB - user_objects_dealloc_MB desc





      
END

IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR TABLE_SIZE = 1)
BEGIN
select '*********DATABASE >>' + db_name() + '<< TABLE_SIZE*****************' as QueryMode
      SELECT
      OBJECT_NAME(i.OBJECT_ID) AS TableName,
      (8 * SUM(a.used_pages))/1024.00 AS 'TableSize(MB)'
FROM 
      sys.indexes AS i
            JOIN 
      sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
            JOIN 
      sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY 
      i.OBJECT_ID
ORDER BY 
      (8 * SUM(a.used_pages))/1024.00  desc

END
IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR CONFIG = 1)
BEGIN
select '***************Disk Free Size***************' as QueryMode      
EXEC master.sys.xp_fixeddrives;
select '***************File Size***************' as QueryMode
Select      
      DB_NAME(database_id) AS [Database Name],      
      Name,       
      physical_name 
      PhysicalName,     
      cast(size as bigint) * 8192 / 1024 /1024 as Size_MB      
From 
      sys.master_files      
Order By 
      cast(size as bigint) * 8192 / 1024 /1024 desc

select '***************Server Info***************' as QueryMode
SELECT 
          SERVERPROPERTY('MachineName') as Host,
          SERVERPROPERTY('InstanceName') as Instance,
          SERVERPROPERTY('Edition') as Edition, /*shows 32 bit or 64 bit*/
          SERVERPROPERTY('ProductLevel') as ProductLevel, /* RTM or SP1 etc*/
          Case SERVERPROPERTY('IsClustered') when 1 then 'CLUSTERED' else
      'STANDALONE' end as ServerType,
          @@VERSION as VersionNumber
select '***************Server level configuration***************' as QueryMode
SELECT * from sys.configurations order by NAME

select '***************Trace Status***************' as QueryMode
DBCC TRACESTATUS(-1);
select '***************Database Level***************' as QueryMode
SELECT name,compatibility_level,recovery_model_desc,state_desc  FROM sys.databases
select '*************** location of the database***************' as QueryMode
SELECT db_name(database_id) as DatabaseName,name,type_desc,physical_name FROM sys.master_files
select '*************** Backup Status***************' as QueryMode
SELECT db.name, 
case when MAX(b.backup_finish_date) is NULL then 'No Backup' else convert(varchar(100), 
      MAX(b.backup_finish_date)) end AS last_backup_finish_date
FROM sys.databases db
LEFT OUTER JOIN msdb.dbo.backupset b ON db.name = b.database_name AND b.type = 'D'
      WHERE db.database_id NOT IN (2) 
GROUP BY db.name
ORDER BY 2 DESC

END

IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR [REPLICATION ERROR] = 1)
BEGIN
select '***************Replication Error***************' as QueryMode
SELECT TOP 100
         id
        ,time
        ,error_type_id
        ,source_type_id
        ,source_name
        ,error_code
        ,error_text
        ,xact_seqno
        ,command_id
        ,session_id
FROM     distribution.dbo.MSrepl_errors WITH ( NOLOCK )
WHERE    time > DATEADD(mi , -60 , GETDATE())
ORDER BY id
END
IF EXISTS (SELECT 1 FROM @MODE WHERE [ALL] = 1 OR [REPLICATION] = 1)
BEGIN

select '***************Replication Status***************' as QueryMode



SELECT DISTINCT
         @@SERVERNAME AS SrvName
        ,A.article_id
        ,A.Article
        ,P.Publication
     --,S.agent_id
        ,SUBSTRING(Agents.[name] , 14 , 50) AS [Name]
        ,UndelivCmdsInDistDB
        ,DelivCmdsInDistDB
FROM     distribution.dbo.MSdistribution_status AS s
         INNER JOIN distribution.dbo.MSdistribution_agents AS Agents
            ON Agents.[id] = S.agent_id
         INNER JOIN distribution.dbo.MSpublications AS P
            ON P.publication = Agents.publication
         INNER JOIN distribution.dbo.MSarticles AS A
            ON A.article_id = S.article_id
               AND P.publication_id = A.publication_id
WHERE    1 = 1
         AND UndelivCmdsInDistDB <> 0
--AND P.Publisher_db = 'FX'
--AND A.Article IN('MD_VolatilitySurface') -- 'Forwards%'
--AND P.Publication = 'IR_SDDP'
--AND S.agent_id NOT IN (245, 246, 253, 254)
--AND SUBSTRING(Agents.[name], 16, 50) LIKE '%HST-IR_HST-IREQ-SQL-UK-104%'
ORDER BY UndelivCmdsInDistDB DESC
----SET STATISTICS PROFILE OFF;

END
 
 
 /*
 	Daniel Sass
OPS DBA TL.
T.  +972 3 719 6039
M. +972 54 268 8612
E.  d.sass@sdgm.com
W. www.sdgm.com

*/

