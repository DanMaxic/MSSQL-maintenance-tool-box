
SELECT top 10 
		Db_Name(a.database_id) AS [Database Name]
		,CASE  WHEN a.file_id = 2 THEN 'L' ELSE 'D' END AS [File Type]
		,UPPER(SUBSTRING(b.physical_name, 1, 1)) AS [File location]
		,SUM(a.size_on_disk_bytes)/1048576.0 AS [siz disk (Mb)]
		,SUM(a.io_stall) AS [io_stall]


		,SUM(a.num_of_reads) AS [Reads count]
		,((100* SUM(a.num_of_reads)/SUM(a.num_of_reads + a.num_of_writes))) AS [Reads Precentage]
		,((100* SUM(a.io_stall_read_ms)/SUM(a.io_stall_write_ms + a.io_stall_read_ms))) AS [reads stall Precentage]
		,SUM(a.num_of_bytes_read)/1048576.0 AS [Reads (Mb)]
		,SUM(a.io_stall_read_ms) AS [reads stall (ms)]

		,SUM(a.num_of_writes) AS [Writes count]
		,((100* SUM(a.num_of_writes)/SUM(a.num_of_reads + a.num_of_writes))) AS [Writes Precentage]
		,((100* SUM(a.io_stall_write_ms)/SUM(a.io_stall_write_ms + a.io_stall_read_ms))) AS [Writes stall Precentage]
		,SUM(a.num_of_bytes_written)/1048576.0 AS num_of_bytes_written
		,SUM(a.io_stall_write_ms) AS io_stall_write_ms
FROM sys.dm_io_virtual_file_stats (NULL, NULL) a 
JOIN sys.master_files b ON a.file_id = b.file_id 
AND a.database_id = b.database_id
group by a.database_id,(CASE  WHEN a.file_id = 2 THEN 'L' ELSE 'D' END),UPPER(SUBSTRING(b.physical_name, 1, 1))
order by io_stall desc