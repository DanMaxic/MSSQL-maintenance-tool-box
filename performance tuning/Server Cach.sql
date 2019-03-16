--USE master;
--GO
--set transaction isolation level read uncommitted

--go
--	set STATISTICS  io on
--go
--	set STATISTICS  io on
--go

go


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


go

create table ##tmpColl(PageCount bigint,DbName varchar(128),name varchar(128),index_id bigint);


insert into ##tmpColl exec sp_msforeachdb ' use [?];



SELECT COUNT(*)   PageCount ,DB_Name(),name ,index_id 

FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (			
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.partition_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = db_id()
GROUP BY name, index_id 
ORDER BY 1 DESC; ';

select top 20 * from ##tmpColl order by 1 desc
drop table ##tmpColl


