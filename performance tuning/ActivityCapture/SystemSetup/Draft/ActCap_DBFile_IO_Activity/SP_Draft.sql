/******/
Declare @input_string nvarchar(1024)='Drive Reads,Drive Writes,DB Activity:Total (Reads)';
declare @DebugMode		bit = 1;
/******/

set transaction isolation level read uncommitted;
set nocount on;

declare @CaptureMode varchar(5) = '1Sec';

Declare @CaptureAndMergeStatement Nvarchar(max);

Declare @Reports	table([Report Name] Nvarchar(100),[GetIt] bit	Default(0),[ShowIt] bit	Default(0));
insert into @Reports ([Report Name],[GetIt])values ('Show All Aviable Reports',1);
insert into @Reports ([Report Name])values ('Drive Total Activity');
insert into @Reports ([Report Name])values ('Drive Reads');
insert into @Reports ([Report Name])values ('Drive Writes');
insert into @Reports ([Report Name])values ('DB Activity:Total (Reads and Writes)');
insert into @Reports ([Report Name])values ('DB Activity:Total (Reads)');
insert into @Reports ([Report Name])values ('DB Activity:Total (Writes)');
insert into @Reports ([Report Name])values ('DataFile Activity(Reads and Writes)');
insert into @Reports ([Report Name])values ('DataFile Activity(Reads)');
insert into @Reports ([Report Name])values ('DataFile Activity(Writes)');
insert into @Reports ([Report Name])values ('DataFile Growth (Data)');
insert into @Reports ([Report Name])values ('Database Growth (Data)');
insert into @Reports ([Report Name])values ('Database Growth (Log)');


	update  @Reports
	set		[GetIt] = 1
	where @input_string like ('%'+[Report Name] +'%');



-- Final ResultSet 
IF NOT EXISTS (SELECT * FROM tempdb.sys.objects WHERE name like '##SQLTskMGR_IOCOL_' AND type in (N'U'))
BEGIN
	PRINT 'creating spot table name=[##SQLTskMGR_IOCOL_]';
	CREATE TABLE [##SQLTskMGR_IOCOL_]
	(
	[Ctime] [datetime] NULL,
	[CaptureMode] [nvarchar](128) NULL,
	[Db_Name] [nvarchar](128) NULL,
	[FileName] [nvarchar](128) NULL,
	[db_file_type] [nvarchar](5) NULL,
	[disk_location] [nvarchar](5) NULL,
	[database_id] [smallint] NULL,
	[file_id] [smallint] NULL,
	[num_of_reads] [bigint] NULL,
	[num_of_bytes_read] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[num_of_bytes_written] [bigint] NULL,
	[size_on_disk_bytes] [bigint] NULL
	);

END;


Declare @tmp as table  (
		[action]				nvarchar(10)
		,[Ctime]					datetime
		,[CaptureMode]			nvarchar(128)
		,[Db_Name]				nvarchar(128)
		,[FileName]				nvarchar(128)
		,[db_file_type]			nvarchar(5)
		,[disk_location]		nvarchar(5)
		,[database_id]			smallint
		,[file_id]				smallint
		,[num_of_reads]			bigint
		,[num_of_bytes_read]	bigint
		,[num_of_writes]		bigint
		,[num_of_bytes_written]	bigint
		,[size_on_disk_bytes]	bigint
		)
set @CaptureAndMergeStatement= '
-- Temporarly ResultSet 
IF NOT EXISTS (SELECT * FROM tempdb.sys.objects WHERE name like ''##SPTTABLE_'+@CaptureMode+''' AND type in (N''U''))
BEGIN
	PRINT ''creating spot table name=[##SPTTABLE_'+@CaptureMode+']'';
	CREATE TABLE [##SPTTABLE_'+@CaptureMode+']
	(
		[Db_Name]				nvarchar(128)
		,[FileName]				nvarchar(128)
		,[db_file_type]			nvarchar(5)
		,[disk_location]		nvarchar(5)
		,[database_id]			smallint
		,[file_id]				smallint
		,[num_of_reads]			bigint
		,[num_of_bytes_read]	bigint
		,[num_of_writes]		bigint
		,[num_of_bytes_written]	bigint
		,[size_on_disk_bytes]	bigint
	);

END;

Merge [##SPTTABLE_'+@CaptureMode+'] AS TARGET
USING (SELECT 
		[Db_Name]=Db_Name(a.database_id)
		,[FileName]=b.name		
		,[db_file_type] = CASE  WHEN a.file_id = 2 THEN ''L'' ELSE ''D'' END 
		,[disk_location] = UPPER(SUBSTRING(b.physical_name, 1, 1)) 
		,a.database_id
		,a.file_id
		,a.num_of_reads
		,a.num_of_bytes_read		
		,a.num_of_writes
		,a.num_of_bytes_written		
		,a.size_on_disk_bytes  
FROM sys.dm_io_virtual_file_stats (NULL, NULL) a 
JOIN sys.master_files b ON a.file_id = b.file_id 
AND a.database_id = b.database_id) AS Source
ON (	(Target.database_id =Source.database_id)
		AND
		(Target.file_id =Source.file_id)
	)
WHEN MATCHED 
	THEN UPDATE SET 
					Target.num_of_reads =Source.num_of_reads
					,Target.num_of_writes =Source.num_of_writes
					,Target.num_of_bytes_read =Source.num_of_bytes_read
					,Target.num_of_bytes_written =Source.num_of_bytes_written
					,Target.size_on_disk_bytes =Source.size_on_disk_bytes
WHEN NOT MATCHED
		THEN INSERT	(	[Db_Name]
						,[FileName]
						,[db_file_type]
						,[disk_location]
						,[database_id]
						,[file_id]

						,[num_of_reads]
						,[num_of_bytes_read]
						,[num_of_writes]
						,[num_of_bytes_written]
						,[size_on_disk_bytes])
		VALUES	(	Source.[Db_Name]
					,Source.[FileName]
					,Source.[db_file_type]
					,Source.[disk_location]
					,Source.[database_id]
					,Source.[file_id]

					,Source.[num_of_reads]
					,Source.[num_of_bytes_read]
					,Source.[num_of_writes]
					,Source.[num_of_bytes_written]
					,Source.[size_on_disk_bytes]
					)

OUTPUT 
		$action		as [action]
		,GetDate()	as [Ctime]
		,'''+@CaptureMode+''' as [CaptureMode]
		,Inserted.[Db_Name]
		,Inserted.[FileName]
		,Inserted.[db_file_type]
		,Inserted.[disk_location]
		,Inserted.database_id
		,Inserted.file_id
		,Inserted.num_of_reads - isnull(deleted.num_of_reads,0)						as [num_of_reads]
		,Inserted.num_of_writes - isnull(deleted.num_of_writes,0)						as [num_of_writes]
		,Inserted.num_of_bytes_read - isnull(deleted.num_of_bytes_read,0)				as [num_of_bytes_read]
		,Inserted.num_of_bytes_written - isnull(deleted.num_of_bytes_written,0)		as [num_of_bytes_written]
		,Inserted.size_on_disk_bytes - isnull(deleted.size_on_disk_bytes,0)			as [size_on_disk_bytes]
		;
		
';
--DebugMode
IF (@DebugMode = 1)
BEGIN
	print @CaptureAndMergeStatement;
END
insert into @tmp exec sp_executesql @CaptureAndMergeStatement;
insert into [##SQLTskMGR_IOCOL_] 
select [Ctime]
		,[CaptureMode]
		,[Db_Name]
		,[FileName]
		,[db_file_type]
		,[disk_location]
		,[database_id]
		,[file_id]
		,[num_of_reads]
		,[num_of_bytes_read]
		,[num_of_writes]
		,[num_of_bytes_written]
		,[size_on_disk_bytes] 
FROM @tmp where [action] !='INSERT';

--================================================================REPORTS

--Breaks out if report not exists
if not exists (select 1 from ##SQLTskMGR_IOCOL_) return;

Declare @Db_Name varchar(1024) = '';	
Declare @DataFile varchar(1024) = '';	
Declare @disk_location varchar(128) = '';	
Declare @DateSearcher varchar(128) = '1=1';	
--DISK LIST
select @disk_location =@disk_location+ ('['+[disk_location] + '],') from ##SQLTskMGR_IOCOL_ group by [disk_location];
set @disk_location =LEFT(@disk_location, LEN(@disk_location) - 1);
--DbName LIST
select @Db_Name =@Db_Name+ ('['+[Db_Name] + '],') from ##SQLTskMGR_IOCOL_ group by [Db_Name];
set @Db_Name =LEFT(@Db_Name, LEN(@Db_Name) - 1);
--DataFile	LIST
select @DataFile =@DataFile+ ('['+[FileName] + '],') from ##SQLTskMGR_IOCOL_ where [db_file_type] = 'D' group by [FileName];
set @DataFile =LEFT(@DataFile, LEN(@DataFile) - 1);
DECLARE @DynamicPivotReportGenerator NVARCHAR(MAX)= '';

if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Show All Aviable Reports'  )
BEGIN
	select * from @Reports;
	if @DebugMode=1 print 'select * from @Reports;';
	exec (@DynamicPivotReportGenerator);
END

if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Drive Total Activity')
BEGIN	
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@disk_location+'
	FROM
		(SELECT	[Ctime],[disk_location],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_ 
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [disk_location] in ('+@disk_location+')
	) AS PivotTable order by 1 asc;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Drive Reads')
BEGIN	
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@disk_location+'
	FROM
		(SELECT	[Ctime],[disk_location],	([num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_ 
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [disk_location] in ('+@disk_location+')
	) AS PivotTable order by 1 asc;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END
--

if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Drive Writes')
BEGIN	
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@disk_location+'
	FROM
		(SELECT	[Ctime],[disk_location],	([num_of_bytes_read]) as IOAct
			from ##SQLTskMGR_IOCOL_ 
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [disk_location] in ('+@disk_location+')
	) AS PivotTable order by 1 asc;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END
--
--- Pivot Report by DB Activity (Reads and Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DB Activity:Total (Reads and Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

--- Pivot Report by DB Activity (Reads)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DB Activity:Total (Reads)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_read]) as IOAct
			from ##SQLTskMGR_IOCOL_
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

--- Pivot Report by DB Activity (Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DB Activity:Total (Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_
			WHERE [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END


--- Pivot Report by DataFile Activity (Reads and Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DataFile Activity(Reads and Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

--- Pivot Report by DataFile Activity (Reads and Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DataFile Activity(Reads)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([num_of_bytes_read]) as IOAct
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END
--- Pivot Report by DataFile Activity (Reads and Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DataFile Activity(Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([num_of_bytes_written]) as IOAct
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END
--- Pivot Report by DataFile Activity (Reads and Writes)
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'DataFile Growth (Data)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([size_on_disk_bytes]) as Groth
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

--- Pivot Report by Database Growth
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Database Growth (Data)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([size_on_disk_bytes]) as Groth
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''D'' 
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

--- Pivot Report by Database Growth
if exists(select 1 from @Reports where [GetIt] = 1 and  [Report Name] = 'Database Growth (Log)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([size_on_disk_bytes]) as Groth
			from ##SQLTskMGR_IOCOL_ where [db_file_type] = ''L'' 
			AND [CaptureMode] = '''+@CaptureMode+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	';
	if @DebugMode=1 print @DynamicPivotReportGenerator;
	exec (@DynamicPivotReportGenerator);
END

