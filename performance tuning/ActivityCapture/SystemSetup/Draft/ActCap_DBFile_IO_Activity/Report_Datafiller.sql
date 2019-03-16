USE [PerfDB]
GO

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values('Drive Activity'
			,'IO Performance'
           ,'Drive Activity in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''Drive Activity'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values ('DB Activity:Total (Reads)'
			,'IO Performance'
           ,'DB Activity Only Reads in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''DB Activity:Total (Reads)'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values ('DB Activity:Total (Writes)'
           ,'IO Performance'
		   ,'DB Activity Only Writes in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''DB Activity:Total (Writes)'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values('DataFile Activity'
           ,'IO Performance'
		   ,'DataFile Activity both Reads and Writes in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''DataFile Activity'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values('DataFile Growth'
           ,'IO Performance'
		   ,'DB Activity both Reads and Writes in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''DataFile Growth'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values('Database Growth (Data)'
           ,'IO Performance'
		   ,'DB Activity both Reads and Writes in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''Database Growth (Data)'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');

INSERT INTO [ActCap].[PivotReport_Config]([ReportName],[ReportCategory],[ReportDescription],[ExecutionExample],[DefaultCaptureSetName],[DefaultTimeRange],[ReportBuild],[ReportExecutionCode])
values('Database Growth (Log)'
           ,'IO Performance'
		   ,'DB Activity both Reads and Writes in Bytes'
           ,'perfdb.[ActCap].[PivotReport_Activity] @ReportName = ''Database Growth (Log)'',@CaptureSet = ''1mm'''
           ,'1mm'
           ,''
           ,'1.0.0.1'
           ,'');
GO


