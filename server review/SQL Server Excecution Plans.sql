
select (sum(single_pages_kb) + sum(multi_pages_kb) ) * 8  / (1024.0) as [cached_plans  size (MB)]
from sys.dm_os_memory_cache_counters
where type = 'CACHESTORE_SQLCP' or type = 'CACHESTORE_OBJCP'


select top 10 
	CASE dbid 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE db_name(dbid) 
        END AS database_name
	--,count(*) count
	,SUM(qs.size_in_bytes)/1024/1024 [Size (Mb)]
	,100.0 * COUNT(*) / SUM (COUNT(*)) OVER() AS [Percentage]


from sys.dm_exec_cached_plans qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) qt
group by (qt.dbid)
order by 3 desc