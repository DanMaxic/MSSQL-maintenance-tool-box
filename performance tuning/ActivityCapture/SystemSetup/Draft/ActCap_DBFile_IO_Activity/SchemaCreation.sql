Use [PerfDB]
GO
Create Schema ActCap;
GO
Create Table ActCap.ActCap_DBFile_IO_Activity(
		[Ctime]					datetime
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
		);
GO
Create Table [ActCap].[PivotReport_Config]
(
	[ReportName]				NVARCHAR(128) Primary key
	,[ReportDescription]		NVARCHAR(1024)
	,[ReportOwner]				NVARCHAR(128) Default(ORIGINAL_LOGIN())
	,[ExecutionExample]			NVARCHAR(1024)
	,[DefaultCaptureSetName]	varchar(5)
	,[DefaultTimeRange]			varchar(5)	
	,[ReportBuild]				varchar(20)	
	,[ReportVersion]			INT
	,[CreationDate]				DateTime Default(GetDate())	
	,[LastModified]				DateTime
	,[ReportExecutionCode]		NVARCHAR(max)
);
GO
CREATE TRIGGER [ActCap].[PivotReport_Config_ReprtUpdated]
ON [ActCap].[PivotReport_Config]
FOR UPDATE
AS BEGIN
  UPDATE [ActCap].[PivotReport_Config] SET [LastModified] = GETDATE(), [ReportVersion] = [ReportVersion] +1
  FROM INSERTED
  WHERE inserted.[ReportName]=[ActCap].[PivotReport_Config].[ReportName]
END

GO