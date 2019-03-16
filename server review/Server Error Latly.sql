;with  RING_BUFFER_EXCEPTION AS (
	SELECT CONVERT (varchar(30), GETDATE(), 121) as [RunTime],
	dateadd (ms, (rbf.[timestamp] - tme.ms_ticks), GETDATE()) as Time_Stamp,
	cast(record as xml).value('(//Exception//Error)[1]', 'varchar(255)') as [Error],
	cast(record as xml).value('(//Exception/Severity)[1]', 'varchar(255)') as [Severity],
	cast(record as xml).value('(//Exception/State)[1]', 'varchar(255)') as [State],
	msg.description,
	cast(record as xml).value('(//Exception/UserDefined)[1]', 'int') AS [isUserDefinedError],
	cast(record as xml).value('(//Record/@id)[1]', 'bigint') AS [Record Id],
	cast(record as xml).value('(//Record/@type)[1]', 'varchar(30)') AS [Type], 
	cast(record as xml).value('(//Record/@time)[1]', 'bigint') AS [Record Time],
	tme.ms_ticks as [Current Time]
from sys.dm_os_ring_buffers rbf
cross join sys.dm_os_sys_info tme
cross join sys.sysmessages msg
where rbf.ring_buffer_type = 'RING_BUFFER_EXCEPTION'
and msg.error = cast(record as xml).value('(//Exception//Error)[1]', 'varchar(500)') and msg.msglangid = 1033 
)
select Error,description,COUNT(*)
from RING_BUFFER_EXCEPTION
Group by Error,description