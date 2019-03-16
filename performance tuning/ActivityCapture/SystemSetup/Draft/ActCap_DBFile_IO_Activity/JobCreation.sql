USE [msdb]
GO
set xact_abort ON
go

DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'OPS_ActivityCapture', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
DECLARE @sername nvarchar(128) = @@servername;
EXEC msdb.dbo.sp_add_jobserver @job_name=N'OPS_ActivityCapture', @server_name = @sername
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'OPS_ActivityCapture', @step_name=N'Capture_DBFile_IO_Activity', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec ActCap.Capture_DBFile_IO_Activity @CaptureMode = ''10MM''
', 
		@database_name=N'PerfDB', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'OPS_ActivityCapture', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'OPS_ActivityCapture', @name=N'1mm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130325, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO


GO
EXEC msdb.dbo.sp_update_schedule @name=N'1mm'
		,@freq_subday_interval=10
GO
