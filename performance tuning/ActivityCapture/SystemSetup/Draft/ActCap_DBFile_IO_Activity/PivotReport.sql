

Use Perfdb
go

CREATE proc [ActCap].[PivotReport_Activity] 
				@ReportName			nvarchar(max)	= NULL
				,@CaptureSet		varchar(5)		= NULL
				,@DateRange			nvarchar(max)	= NULL
				,@DateRangeStart	datetime		= NULL
				,@DateRangeEnd		datetime		= NULL
				,@DebugMode			bit =0

AS



--IF REPORT INVALID OR EMPTY OR NOT EXIST
IF ((@ReportName='')OR (@ReportName is null)OR(not exists(select 1 from [ActCap].[PivotReport_Config] where [ReportName] = @ReportName)))
BEGIN
	select [Message]='Report name not provided or not exist, see the report from The following list';
	SELECT 
		[ReportName]
		,[ReportOwner]
		,[ReportCategory]
		,[ReportDescription]
		,[ExecutionExample]
		,[DefaultCaptureSetName]
		,[DefaultTimeRange]
		,[ReportBuild]
		,[ReportVersion]
		,[CreationDate]
		,[LastModified]
	FROM [ActCap].[PivotReport_Config]
	RETURN;
END

--IF Capture SET not prodided or not exists, try to get one, if no default in fonfig file-> rais error
IF ((@CaptureSet='')OR(@CaptureSet is null))
BEGIN
	print '@CaptureSet wasnt provided, trying to get report default';
	SET @CaptureSet	= (select 1 [DefaultCaptureSetName] from [ActCap].[PivotReport_Config] where [ReportName] = @ReportName);
	IF (@CaptureSet IS NULL)
	BEGIN
		select [Message]='Report name not provided or not exist, see the report from The following list';
		RETURN;
	END
END

--IF System Default, Get only from day
IF ((@DateRangeStart IS NULL) OR (@DateRangeEnd IS NULL)OR (@DateRangeStart ='') OR (@DateRangeEnd =''))
BEGIN
	IF ((@DateRange = '') OR (@DateRange IS NULL) )
	BEGIN
		SET @DateRange =(select [DefaultTimeRange] from [ActCap].[PivotReport_Config] where [ReportName] = @ReportName );
		print '@DateRange wasnt provided, trying to get report default';
		IF (@DateRange IS NULL)
		BEGIN
			select [Message]='DefaultTimeRange name not provided or not exist, see the report referance Or ShortCut referance';
			RETURN;
		END
	END
END
--=======Setting Proccessing
--@DateRange Shortcuts
BEGIN
	--SYSTEM SHORTCUTS::Today
	IF (@DateRange= 'Today') 
	BEGIN
		SET @DateRangeEnd	= GetDate();
		SET @DateRangeStart	=Cast(@DateRangeEnd as date);
	END
	--SYSTEM SHORTCUTS::LastWeek
	IF (@DateRange= 'LastWeek') 
	BEGIN
		SET @DateRangeEnd	= GetDate();
		SET @DateRangeStart	=DATEDIFF(WEEK,-1,@DateRangeEnd);
	END
	--SYSTEM SHORTCUTS::Last24Hours
	IF (@DateRange= 'Last24Hours') 
	BEGIN
		SET @DateRangeEnd	= GetDate();
		SET @DateRangeStart	=DATEDIFF(DAY,-1,@DateRangeEnd);
	END
END



--IF Caller if the 'Query Analyzer' show Caller parameters, and report description
IF ( Program_name() = 'Microsoft SQL Server Management Studio - Query' )
BEGIN
	select	@ReportName			ReportName		
			,@CaptureSet		CaptureSet
			,@DateRange			DateRange
			,@DateRangeStart	DateRangeStart
			,@DateRangeEnd		DateRangeEnd;
END



--exec ActCap.Capture_DBFile_IO_Activity @CaptureMode = '1mm'

--Select * from ActCap.ActCap_DBFile_IO_Activity
print 'Start prepering requested report: '+@ReportName;

-------------GLOBAL REPORTS DECLARATIONS AND Settings
Declare @Db_Name varchar(1024) = '';	
Declare @DataFile varchar(1024) = '';	
Declare @disk_location varchar(128) = '';	
Declare @DateSearcher varchar(128) = '1=1';	

--DISK LIST
select @disk_location =@disk_location+ ('['+[disk_location] + '],') from ActCap.ActCap_DBFile_IO_Activity group by [disk_location];
set @disk_location =LEFT(@disk_location, LEN(@disk_location) - 1);
--DbName LIST
select @Db_Name =@Db_Name+ ('['+[Db_Name] + '],') from ActCap.ActCap_DBFile_IO_Activity group by [Db_Name];
set @Db_Name =LEFT(@Db_Name, LEN(@Db_Name) - 1);
--DataFile	LIST
select @DataFile =@DataFile+ ('['+[FileName] + '],') from ActCap.ActCap_DBFile_IO_Activity where [db_file_type] = 'D' group by [FileName];
set @DataFile =LEFT(@DataFile, LEN(@DataFile) - 1);
	
--Dynamic DateDetarminator
IF ((@DateRangeStart IS NOT NULL) OR (@DateRangeEnd IS NOT NULL))
BEGIN
	SET @DateSearcher = '[Ctime] BETWEEN '''+cast( @DateRangeStart as varchar(50))+''' AND '''+cast(@DateRangeEnd as varchar(50))+''' ';
END


print 'Getting Report Code';
DECLARE @DynamicPivotReportGenerator NVARCHAR(MAX)= '';

select @DynamicPivotReportGenerator=[ReportExecutionCode]from [ActCap].[PivotReport_Config] where [ReportName] = @ReportName;
print @DynamicPivotReportGenerator;
--==REPLACEING DEFUALT PARAMETERS
print '=================================';
SET @DynamicPivotReportGenerator = REPLACE(@DynamicPivotReportGenerator,'''+@disk_location+''',@disk_location);
SET @DynamicPivotReportGenerator = REPLACE(@DynamicPivotReportGenerator,'''''+@CaptureSet+''''',@CaptureSet);
SET @DynamicPivotReportGenerator = REPLACE(@DynamicPivotReportGenerator,'''+@DateSearcher+''',@DateSearcher);
SET @DynamicPivotReportGenerator = REPLACE(@DynamicPivotReportGenerator,'''+@Db_Name+''',@Db_Name);
SET @DynamicPivotReportGenerator = REPLACE(@DynamicPivotReportGenerator,'''+@DataFile+''',@DataFile);

print @DynamicPivotReportGenerator;
exec (@DynamicPivotReportGenerator)


/*---Pivot Report for Drive bytes Activity (Reads and Writes)
IF (@ReportName= '_Drive Activity')
BEGIN	
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@disk_location+'
	FROM
		(SELECT	[Ctime],[disk_location],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ActCap.ActCap_DBFile_IO_Activity 
			WHERE [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [disk_location] in ('+@disk_location+')
	) AS PivotTable order by 1 asc;
	'

END

--- Pivot Report by DB Activity (Reads and Writes)
IF (@ReportName= 'DB Activity:Total (Reads and Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ActCap.ActCap_DBFile_IO_Activity
			WHERE [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
END

--- Pivot Report by DB Activity (Reads)
IF (@ReportName= 'DB Activity:Total (Reads)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_read]]) as IOAct
			from ActCap.ActCap_DBFile_IO_Activity
			WHERE [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
END

--- Pivot Report by DB Activity (Writes)
IF (@ReportName= 'DB Activity:Total (Writes)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([num_of_bytes_written]) as IOAct
			from ActCap.ActCap_DBFile_IO_Activity
			WHERE [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
END

--- Pivot Report by DataFile Activity (Reads and Writes)
IF (@ReportName= 'DataFile Activity')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([num_of_bytes_read]+[num_of_bytes_written]) as IOAct
			from ActCap.ActCap_DBFile_IO_Activity where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(IOAct)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	'
END
--- Pivot Report by DataFile Activity (Reads and Writes)
IF (@ReportName= 'DataFile Growth (Data)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@DataFile+'
	FROM
		(SELECT	[Ctime],[FileName],	([size_on_disk_bytes]) as Groth
			from ActCap.ActCap_DBFile_IO_Activity where [db_file_type] = ''D''
			AND [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [FileName] in ('+@DataFile+')
	) AS PivotTable order by 1 asc ;
	'
END

--- Pivot Report by Database Growth
IF (@ReportName= 'Database Growth (Data)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([size_on_disk_bytes]) as Groth
			from ActCap.ActCap_DBFile_IO_Activity where [db_file_type] = ''D'' 
			AND [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
END

--- Pivot Report by Database Growth
IF (@ReportName= 'Database Growth (Log)')
BEGIN
	SET @DynamicPivotReportGenerator = 
	'select [Ctime] as CaptureDate ,'+@Db_Name+'
	FROM
		(SELECT	[Ctime],[Db_Name],	([size_on_disk_bytes]) as Groth
			from ActCap.ActCap_DBFile_IO_Activity where [db_file_type] = ''L'' 
			AND [CaptureMode] = '''+@CaptureSet+'''
			AND '+@DateSearcher+'
		)  AS SourceTable
	PIVOT 
	(
		SUM(Groth)
		FOR [Db_Name] in ('+@Db_Name+')
	) AS PivotTable order by 1 asc ;
	'
END
*/

