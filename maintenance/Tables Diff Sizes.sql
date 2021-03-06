
declare @D1 date = getdate();
declare @D2 date = DateAdd(day,-7,@d1);
declare @D3 date = DateAdd(day,-14,@d1);
select getdate()[Today],@d1 [1 Week],@d2 [2 Week]

 select '<---------DB Level--------->' [ ]
  SELECT 
		t1.[SrvName]
      ,t2.[DBName]
       ,(t1.[DataAllocMB]-t2.[DataAllocMB]) AS [DataAllocMB--Growth -1Week] 
      ,(t1.[DataUsedMB]-t2.[DataUsedMB]) AS [DataUsedMB -Growth -1Week]
	  ,(t1.[DataAllocMB]-t3.[DataAllocMB]) AS [DataAllocMB--Growth -2Weeks] 
      ,(t1.[DataUsedMB]-t3.[DataUsedMB]) AS [DataUsedMB--Growth -2Weeks]
  FROM [PerfDB].[Capacity].[DataBasesCapacity] t1 --today
  inner join [PerfDB].[Capacity].[DataBasesCapacity] t2   on t1.DBName = t2.DBName --LastWeek
    inner join [PerfDB].[Capacity].[hist_DataBasesCapacity] t3   on t1.DBName = t3.DBName --LastWeek
  where t1.[RunDate] = @D1
		AND t2.[RunDate] = @D2
			AND t3.[RunDate] = @D3
	-------------
	AND t1.[DBName] != 'PerfDB'
AND (t1.[DataAllocMB]-t2.[DataAllocMB]) > 20
 order by 4 desc
 select '<---------Object Level--------->' [ ]

 SELECT 
		t1.[SrvName]
      ,t2.[DBName]
   --   ,convert(varchar(15),t1.[RunDate]) +' '+ convert(varchar(15),t1.[RunTime]) d1
	  --,convert(varchar(15),t2.[RunDate]) +' '+ convert(varchar(15),t2.[RunTime]) d2
      ,t1.[SchemaName] +'.'+t1.[TableName] as [ObjectName]
      ,(t1.[Row_Count]-t2.[Row_Count]) AS [Rows-Growth -1Week] 
      ,(t1.[Reserved_MB]-t2.[Reserved_MB]) AS [MB-Growth -1Week]
      ,(t1.[Row_Count]-t3.[Row_Count]) AS [Rows-Growth -2Weeks] 
      ,(t1.[Reserved_MB]-t3.[Reserved_MB]) AS [MB-Growth -2Weeks]
	  	  ,('Exec '+t1.[DBName]+'..SP_help''' +t1.[SchemaName]+'.'+t1.[TableName]+''' ') as [sp_help]
	  ,('Exec '+t1.[DBName]+'..SP_Spaceused''' +t1.[SchemaName]+'.'+t1.[TableName]+''' ') as [sp_spaceused]
  FROM [PerfDB].[Capacity].[TablesSize] t1 --today
  inner join [PerfDB].[Capacity].[TablesSize] t2 --LastWeek
	on t1.DBName = t2.DBName AND  t1.[SchemaName] = t2.[SchemaName]  AND t1.[TableName] = t2.[TableName]
	 inner join [PerfDB].[Capacity].[hist_TablesSize] t3 --Last 2Week
	on t1.DBName = t3.DBName AND  t1.[SchemaName] = t3.[SchemaName]  AND t1.[TableName] = t3.[TableName]
  where t1.[RunDate] = @D1 --Today
		AND t2.[RunDate] = @D2
			AND t3.[RunDate] = @D3
	-------------
	AND t1.[DBName] != 'PerfDB'
	AND (t1.[Reserved_MB]-t2.[Reserved_MB]) > 20
  order by 5 desc

