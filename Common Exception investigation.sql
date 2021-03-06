
USE master;
GO
set transaction isolation level read uncommitted
go

Declare @ID varchar(50);
SELECT TOP 1 @ID= [InstanceID]
  FROM [Common].[dbo].[Exceptions_Configuration];
 
SELECT 
		ee.[ExceptionID]		[ExceptionID]
		,pe.[PublishID]
		,ee.[ExceptionTime]
		,es.[ComponentName]
		,es.[MachineName]
		,ee.[ExceptionType]		[ExceptionType]
		,ee.[Message]			[Main Exception Message]		
		--,inner_ex.[Message] 
		
		,ed.[ExceptionDataID]
		, cast(('http://ir-dev-web/Common/Exceptions/ExceptionPublish.aspx?RequestHandlerKey=' +@ID+ '&PublishID='+(cast(pe.[PublishID] as varchar))) as varchar(max))			[Common portal link]
		
  FROM 
		[Common].[dbo].[Exceptions_Exceptions]	ee
	inner join 
		[Common].[dbo].[Exceptions_Sources]		es on ee.[SourceID] = es.[SourceID]
	inner join 
	  (
								SELECT [ExceptionID],[Message]
								FROM [Common].[dbo].[Exceptions_Exceptions]  
								  where [Message] like 'Timeout expired.%'
		) as inner_ex ON ee.[InnerExceptionID]= inner_ex.[ExceptionID]
	LEFT join [Common].[dbo].[Exceptions_PublishExceptions] pe on pe.[ExceptionID] = ee.[ExceptionID]
	Left join [Common].[dbo].[Exceptions_Data] ED on ee.[ExceptionID] = ED.[ExceptionID]
where 
		ED.[DataKey] = 'SqlCommandData'
	--AND
	--	es.[ComponentName]='SD.IR.MTMService'

order by [ExceptionTime] desc