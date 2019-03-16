DECLARE @PArtitionedTables AS table  ([database name] sysname,[Table Count] int,lock_escalation_desc varchar(10)  );
insert into @PArtitionedTables exec sys.sp_MSforeachdb '
		use [?];
		print ''[?]''
		SELECT DB_NAME() [database name],COUNT(*) AS [Table Count],lock_escalation_desc FROM sys.tables as t
		inner join (
			select object_id
		FROM sys.partitions 
		where index_id in (1,0) AND DB_ID() >4
		group by object_id,index_id HAVING COUNT(*) > 1
		) AS  p on t.object_id = p.object_id
		GROUP BY lock_escalation_desc
		';

select * from @PArtitionedTables;


SELECT DB_NAME() [database name],COUNT(*) AS [Table Count],lock_escalation_desc FROM sys.tables as t
		inner join (
			select object_id
		FROM sys.partitions 
		where index_id in (1,0) AND DB_ID() >4
		group by object_id,index_id HAVING COUNT(*) > 1
		) AS  p on t.object_id = p.object_id
		GROUP BY lock_escalation_desc