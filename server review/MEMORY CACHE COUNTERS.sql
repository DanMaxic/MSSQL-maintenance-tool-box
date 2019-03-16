select 
	top 10

name,REPLACE([type],'_',' ') AS [type],(sum(single_pages_kb) + sum(multi_pages_kb) ) * 8  / (1024.0) as [Object Size (MB)]
from sys.dm_os_memory_cache_counters
--where type = 'CACHESTORE_SQLCP' or type = 'CACHESTORE_OBJCP'
GROUP BY name,[type]
order by 3 DESC
