
--HKLM\HARDWARE\DESCRIPTION\System\BIOS
--SystemManufacturer
DECLARE @LastSystemRestart Datetime;
select @LastSystemRestart=create_date from sys.databases where database_id = 2
DECLARE @SystemManufacturer varchar(20);
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE',
  @key='HARDWARE\DESCRIPTION\System\BIOS',
  @value_name='SystemManufacturer',
  @value=@SystemManufacturer OUTPUT;
DECLARE @SystemModal varchar(20);
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE',
  @key='HARDWARE\DESCRIPTION\System\BIOS',
  @value_name='SystemProductName',
  @value=@SystemModal OUTPUT;
DECLARE @OSVersion Nvarchar(1024);
exec master..xp_regread
                     N'HKEY_LOCAL_MACHINE'
                    , N'SOFTWARE\Microsoft\Windows NT\CurrentVersion'
                    , N'ProductName',@OSVersion OUTPUT;
DECLARE @ProcessorNameString Nvarchar(1024);
exec master..xp_regread
                     N'HKEY_LOCAL_MACHINE'
                    , N'HARDWARE\DESCRIPTION\System\CentralProcessor\0\'
                    , N'ProcessorNameString',@ProcessorNameString OUTPUT;
	select 
		LastSystemRestart =@LastSystemRestart
		,ProductVersion								=serverproperty('ProductVersion')
		,SQLProductLevel							=SERVERPROPERTY('ProductLevel')  
		,SQLEdition									=serverproperty('Edition')
		,ProcessorNameString						=@ProcessorNameString
		,[Logical CPU]								= (select top 1 cpu_count from sys.dm_os_sys_info)
		,[Physical CPU]								= (select top 1 cpu_count/hyperthread_ratio from sys.dm_os_sys_info)
		--,[Physical Memory (MB)]						= (select top 1 physical_memory_in_bytes/1048576 from sys.dm_os_sys_info)
		,IsClustered								=serverproperty('IsClustered')
		,SecurityMode								=Case convert(int,serverproperty('IsIntegratedSecurityOnly')) when 1 then 'Win based' when  0 then 'Mixed' else 'N\A' end
		,IsSingleUser								=serverproperty('IsSingleUser')
		,ProcessID									=serverproperty('ProcessID')
		,PhysicalNetBIOSName						=serverproperty('ComputerNamePhysicalNetBIOS')
		,host_address								=(select top 1 local_net_address +' : '+convert(varchar,local_tcp_port) from sys.dm_exec_connections where local_net_address is not null)
		,SystemManufacturer							=@SystemManufacturer
		,SystemProductName							=@SystemModal
		,OSVersion									=@OSVersion
		,IsHadrEnabled								=serverproperty('IsHadrEnabled')
		,suspect_pages_Count						=(select top 1 count(*) from msdb..suspect_pages)
		,IsFullTextInstalled						=serverproperty('IsFullTextInstalled')
		,FilestreamShareName						=serverproperty('FilestreamShareName')
		
GO

