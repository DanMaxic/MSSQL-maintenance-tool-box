select StartTime,DatabaseName,ObjectName,TextData,Duration/1000000 as DurationSEC, Reads, Writes, CPU,SessionLoginName from fn_trace_gettable('L:\SQLTRACES\MoreThan4Secs.trc',null)
where SessionLoginName <> 'SHAHAF\administrator'
select id,path,max_files,max_size,start_time,event_count,last_event_time,'select *  from fn_trace_gettable('''+path+''',null)' AS [read trace command] from sys.traces

