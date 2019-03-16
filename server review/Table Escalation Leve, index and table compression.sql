DECLARE @PArtitionedTables AS table  ([database name] sysname,[Table Count] int,data_compression varchar(10)  );
insert into @PArtitionedTables exec sys.sp_MSforeachdb '
		use [?];
		print ''[?]''
SELECT DB_NAME() [database name],COUNT(*) AS [Table Count],data_compression FROM sys.tables as t
		inner join (
			select object_id,COUNT(*) partitionCount,MAX(data_compression) data_compression
		FROM sys.partitions 
		where index_id in (1,0) AND DB_ID() >4 AND rows >0
		group by object_id,index_id HAVING COUNT(*) > 1
		) AS  p on t.object_id = p.object_id
		GROUP BY data_compression
		';
		select * from @PArtitionedTables;
GO
DECLARE @PArtitionedTables AS table  ([database name] sysname,[Indeces Count] int,data_compression varchar(10)  );
insert into @PArtitionedTables exec sys.sp_MSforeachdb '
		use [?];
		print ''[?]''
SELECT DB_NAME() [database name],COUNT(*) AS [Table Count],data_compression FROM sys.tables as t
		inner join (
			select object_id,COUNT(*) partitionCount,MAX(data_compression) data_compression
		FROM sys.partitions 
		where index_id not in (1,0) AND DB_ID() >4 AND rows >0
		group by object_id,index_id HAVING COUNT(*) > 1
		) AS  p on t.object_id = p.object_id
		GROUP BY data_compression
		';
		select * from @PArtitionedTables;