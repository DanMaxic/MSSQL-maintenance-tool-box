select 
	StartTime
	,HostName
	,ApplicationName = 
	CASE 
		WHEN ApplicationName like 'SQLAgent - TSQL JobStep (Job 0x%' 
			THEN (select '{SQL JOB} '+ j.name + ' { step: '+js.step_name+'}'
					from msdb.dbo.sysjobs j
						inner join msdb.dbo.sysjobsteps js on j.job_id = js.job_id
					where ('0x'+master.dbo.fn_hex_to_char(j.job_id)=LEFT(REPLACE(ApplicationName,'SQLAgent - TSQL JobStep (Job ',''),34) ) AND js.step_id = CAST(replace(replace(SUBSTRING(ApplicationName,CHARINDEX(':', ApplicationName) +2,LEN(ApplicationName) -charindex(':',ApplicationName)),')',''),'Step ','') as int)
					)
		ELSE ApplicationName
	end,ApplicationName
	,SessionLoginName
	,tevents.name AS EventName
	,*  
from fn_trace_gettable('D:\MSSQL10_50.MSSQLSERVER\MSSQL\Log\log_407.trc',null) TraceTable
	inner join sys.trace_events tevents on tevents.trace_event_id = TraceTable.EventClass
	WHERE TraceTable.StartTime > '2014-08-18 02:27:15.843'
;
return




select * from sys.trace_events