SELECT top 10 
CASE database_id 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE db_name(database_id) 
        END AS database_name,
        COUNT(*)/128.0 AS Size_MB
,100.0 * COUNT(*) / SUM (COUNT(*)) OVER() AS [Percentage]
    
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY Size_MB DESC;

select COUNT(*)/128.0 AS [SQL Server buffer pool size (MB)]
FROM sys.dm_os_buffer_descriptors