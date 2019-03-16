
/*
	Add PULL Subscriber for a Transactional Replication
	To be Run on the Subscriber
	Run script connected as sa
*/


--- Disable DDL JOB
EXEC msdb.dbo.sp_update_job @job_name = N'OPS_DDLChangeEventChecker' ,
   @enabled = 0
GO

--- Check if DDL Trigger Exists:
EXEC PerfDB.DDLEvent.usp_CheckDDLEventTriggerOnDB @TriggerName = 'TR_DDLChangeEvents'
GO

EXEC msdb.dbo.sp_update_job @job_name = N'OPS_Set_ServerConfigurations' ,
   @enabled = 0
GO

--- Disable DDL Trigger :
EXEC PerfDB.DDLEvent.usp_DisableEnableDDLEventTrigger @pDisableTrigger = 1 ,
   @pIsDebug = 1 , @pIsPrint = 0
GO

--================================================================

USE FI_MD --[<DB NAME>]
GO


DECLARE 
	@pub sysname, 
	@Distrib sysname, 
	@Publisher sysname, 
	@sub sysname,  
	@db sysname, 
	@dest_db sysname, 
	@Desc sysname; 

SELECT   
	 @Distrib	  = N'IREQ-SQL-PR-UK'  --N'DISTRIB-SQL-UK'  ---SET Distributor Server Name	 
	,@Publisher	  = N'IREQ-SQL-PR-UK'     ---SET Publisher Server Name
	,@db		  = N'FI_MD'               ---SET publisher_db
	,@pub		  = N'FI_MD__NRT_OW_4'         ---SET publication Name	
	,@sub 		  = @@SERVERNAME


-- Add pull subscription
PRINT 'Adding pull subscription'
SELECT @Desc = N'Transactional publication of ' + @pub + ' database from Publisher ' + @Publisher ;

EXEC sp_addpullsubscription 
		@publisher					= @Publisher, 
		@publisher_db				= @db, 
		@publication				= @pub, 
		@independent_agent	        = N'True', 
		@subscription_type	        = N'pull', 
		@description				= @Desc,
		@update_mode				= N'read only', 
		@immediate_sync			    = 0 ;


--Add pull subscription agent
PRINT 'Adding pull subscription agent'
EXEC sp_addpullsubscription_agent 
	@publisher							= @Publisher
	,@publisher_db						= @db
	,@publication						= @pub
	,@distributor						= @Distrib	
	,@distributor_security_mode 	    = 1
/*
	,@distributor_security_mode 		= 0
	,@distributor_login					= N'sa'
	,@distributor_password				= N''
*/	
	,@enabled_for_syncmgr				= N'False'
	,@frequency_type					= 64
	,@frequency_interval				= 0
	,@frequency_relative_interval       = 0
	,@frequency_recurrence_factor       = 0
	,@frequency_subday					= 0
	,@frequency_subday_interval 	    = 0
	,@active_start_time_of_day		    = 0
	,@active_end_time_of_day			= 235959
	,@active_start_date					= 0
	,@active_end_date					= 0
	,@alt_snapshot_folder				= N''
	,@working_directory					= N''
	,@use_ftp							= N'False'
	,@publication_type					= 0
GO




--================================================================
--- Enable DDL Trigger :
EXEC PerfDB.DDLEvent.usp_DisableEnableDDLEventTrigger @pDisableTrigger = 0 ,
   @pIsDebug = 1 , @pIsPrint = 0
GO

--- Enable JOB
EXEC msdb.dbo.sp_update_job @job_name = N'OPS_DDLChangeEventChecker' ,
   @enabled = 1
GO

EXEC msdb.dbo.sp_update_job @job_name = N'OPS_Set_ServerConfigurations' ,
   @enabled = 1
GO


--================================================================
/*
use [Subscription]; 
exec sp_droppullsubscription 
	@publisher = @DisPub, 
	@publisher_db = @db, 
	@publication = @pub


use [Subscription]
exec sp_subscription_cleanup
	@publisher = @Publisher, 
	@publisher_db = @db, 
	@publication = @pub

*/