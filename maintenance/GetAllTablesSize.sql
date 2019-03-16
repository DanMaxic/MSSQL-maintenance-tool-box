
--select * from sys.dm_db_index_usage_stats

set transaction isolation level read uncommitted
go

select 
	@@servername [server]
	,db_name() [DB]
	,obs.name
	,inds.rowcnt
	,((inds.reserved)*8) [reserved in kb] 
	,( ((inds.reserved)*8)/(isnull( inds.rowcnt,2))	) [kb per row]
 
from  sys.sysindexes inds
	inner join sys.objects obs on inds.id=obs.object_id 

where	indid in (0,1) 
	AND		obs.is_ms_shipped = 0 
	AND		inds.rowcnt >0
order by 5 desc; 



