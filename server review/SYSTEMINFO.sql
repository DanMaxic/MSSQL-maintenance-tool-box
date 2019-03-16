SET nocount on;


print '<=======	OVERAL WINDOWS ENVARIOMENT =====================>'; 
Declare @enabledXPCMD sql_variant;
select @enabledXPCMD=value_in_use from sys.configurations where name like 'xp_cmdshell';
if (@enabledXPCMD =0)
BEGIN
	EXEC('exec sp_configure ''xp_cmdshell'',1; reconfigure');
END
	declare @sysinfo table(output nvarchar(max));
	INSERT INTO @sysinfo exec xp_cmdshell 'systeminfo';
	DECLARE @output nvarchar(max);
	DECLARE printcursor CURSOR FOR select output from @sysinfo where output is not null and output not like '%]: KB%';
	open printcursor;
	FETCH NEXT FROM printcursor INTO @output;
	while @@FETCH_STATUS=0
	BEGIN
		print @output;
		FETCH NEXT FROM printcursor INTO @output;
	END
	CLOSE printcursor;
	DEALLOCATE printcursor;



/*
SQL SERVER SETTINGS
*/
DECLARE @TraceStatus TABLE (TraceFlag VARCHAR(10),status BIT,Global BIT,Session BIT);
declare @flags nvarchar(max)='';
INSERT  INTO @TraceStatus EXEC ( ' DBCC TRACESTATUS(-1) WITH NO_INFOMSGS');
Select @flags = @flags +TraceFlag + (case when Global=1 then '(Global)' else ''end)+'; '  from @TraceStatus;
Declare @serviceStatus nvarchar(max) = '';
select  @serviceStatus = @serviceStatus+ (servicename + '	; Running under [' + service_account + '] windows permissions. startup mode ' +startup_type_desc+ '
								') from sys.dm_server_services;
Declare @MaxServerMemory nvarchar(50) = '',@MinServerMemory nvarchar(50) = '',@maxMemoryInstalled nvarchar(50);
select top 1 @MaxServerMemory		= cast(value_in_use as nvarchar(50)) from sys.configurations where name ='max server memory (MB)';
select top 1 @MinServerMemory		= cast(value_in_use as nvarchar(50)) from sys.configurations where name ='min server memory (MB)';
select top 1 @maxMemoryInstalled	= cast(physical_memory_in_bytes/1048576 as nvarchar(50)) from sys.dm_os_sys_info;
--CLUSTER CONFIG
DECLARE @ClusertedNode Nvarchar(max) = '';
select @ClusertedNode = @ClusertedNode +(NodeName + '	'+CASE WHEN(NodeName =serverproperty('ComputerNamePhysicalNetBIOS')) then '*ACTIVE' ELSE ''  end) + '
								'   from sys.dm_os_cluster_nodes


/*SQL Server Defualts*/

    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'access check cache bucket count', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'access check cache quota', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Ad Hoc Distributed Queries', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'affinity I/O mask', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'affinity mask', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Agent XPs', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'allow updates', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'awe enabled', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'blocked process threshold', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'c2 audit mode', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'clr enabled', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'cost threshold for parallelism', 5 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'cross db ownership chaining', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'cursor threshold', -1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Database Mail XPs', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'default full-text language', 1033 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'default language', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'default trace enabled', 1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'disallow results from triggers', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'fill factor (%)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'ft crawl bandwidth (max)', 100 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'ft crawl bandwidth (min)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'ft notify bandwidth (max)', 100 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'ft notify bandwidth (min)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'index create memory (KB)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'in-doubt xact resolution', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'lightweight pooling', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'locks', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'max degree of parallelism', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'max full-text crawl range', 4 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'max server memory (MB)', 2147483647 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'max text repl size (B)', 65536 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'max worker threads', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'media retention', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'min memory per query (KB)', 1024 );   
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'min server memory (MB)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'nested triggers', 1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'network packet size (B)', 4096 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Ole Automation Procedures', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'open objects', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'optimize for ad hoc workloads', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'PH timeout (s)', 60 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'precompute rank', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'priority boost', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'query governor cost limit', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'query wait (s)', -1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'recovery interval (min)', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'remote access', 1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'remote admin connections', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'remote proc trans', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'remote query timeout (s)', 600 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Replication XPs', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'RPC parameter data validation', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'scan for startup procs', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'server trigger recursion', 1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'set working set size', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'show advanced options', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'SMO and DMO XPs', 1 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'SQL Mail XPs', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'transform noise words', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'two digit year cutoff', 2049 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'user connections', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'user options', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'Web Assistant Procedures', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'xp_cmdshell', 0 );
    
	/* New values for 2012 */    
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'affinity64 mask', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'affinity64 I/O mask', 0 );
    INSERT  INTO #ConfigurationDefaults
    VALUES  ( 'contained database authentication', 0 );

    /* SQL Server 2012 also changes a configuration default */
    IF @@VERSION LIKE '%Microsoft SQL Server 2005%'
    OR @@VERSION LIKE '%Microsoft SQL Server 2008%' 
    BEGIN 
        INSERT  INTO #ConfigurationDefaults
        VALUES  ( 'remote login timeout (s)', 20 );
    END
    ELSE
    BEGIN
        INSERT  INTO #ConfigurationDefaults
        VALUES  ( 'remote login timeout (s)', 10 );
    END


print '';
print '';
print '';
print '';
print '';
print '<=======	OVERAL SQL ENVARIOMENT ===========>';
	print '	OS Name					:	' +@@version;
	print '	ProductVersion			:	' +convert(nvarchar,serverproperty('ProductVersion'));
	print '	SQLProductLevel			:	' +convert(nvarchar,SERVERPROPERTY('ProductLevel')) ;
	print '	SQLEdition				:	' +convert(nvarchar,serverproperty('Edition'));
	print '	SQL Related services	:	' +@serviceStatus;
	print '	Total Physical Memory	:	' +@maxMemoryInstalled;
	print '	min server memory (MB)	:	'+@MinServerMemory;
	print '	max server memory (MB)	:	'+@MaxServerMemory;
	print '	Trace Flags started		:	'+@flags;	

if (serverproperty('IsClustered')=1)
BEGIN
	print '	SQL Server Clustered	:	TRUE';
	PRINT '	SQL Server Cluster nodes:	'+@ClusertedNode;
END
ELSE BEGIN
	print '	SQL Server Clustered	:	FALSE';	
END



if (@enabledXPCMD =0)
BEGIN
	EXEC('exec sp_configure ''xp_cmdshell'',0; reconfigure');
END
