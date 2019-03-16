
select
	'Microsoft LS System'	LogShipping_Provider	  
	,primary_server			Source_Server
	,primary_database
	,secondary_server		Target_Server
	,secondary_database
	,datediff(minute,last_copied_date_utc,getdate())	Last_Copy
	,datediff(minute,last_restored_date,getdate())		Last_Restore
	,last_restored_latency as restore_Latency
from msdb..log_shipping_monitor_secondary



select top 20 * from msdb..[log_shipping_monitor_error_detail]
order  by log_time desc