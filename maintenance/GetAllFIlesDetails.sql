CREATE TABLE #tbl
(
 FileID			INT
 ,FileGrp		INT
 ,TotalSize		INT
 ,UsedSize		INT
 ,FreeSpace		INT
 ,FreeSpacePrecent	DECIMAL
 ,FILENAME		sysname
 ,FILEPath		sysname
)



--SELECT * FROM sys.sysaltfiles	  WHERE groupid <>0	  /*1048578 = Precentage*/

EXEC sp_MSforeachdb @command1='Use [?]; INSERT INTO #tbl (FileID,FileGrp,TotalSize,UsedSize,FILENAME,FILEPath) EXEC (''DBCC SHOWFILESTATS'')'
UPDATE #tbl SET 
				TotalSize = ((TotalSize * 64)/1024)
				,UsedSize = ((UsedSize *  64)/1024)
				,FreeSpace =	((TotalSize * 64)/1024) - ((UsedSize *  64)/1024)
				,FreeSpacePrecent =		 ((((TotalSize * 64)/1024) -((UsedSize *  64)/1024))*100)/((TotalSize * 64)/1024)

SELECT		@@servername,DB_NAME(tbl2.dbid) AS [DB name],tbl2.name AS [DB File],tbl1.FILEPath AS [Path] ,TotalSize AS [Totalsize MB],UsedSize AS [UsedSize MB],FreeSpace AS [FreeSpace MB],FreeSpacePrecent AS [FreeSpace %]
				  ,	CASE	
							WHEN growth > 100 THEN	(SELECT	CONVERT(sysname, (growth/128))+ ' MB')
							ELSE					(SELECT	CONVERT(sysname, (growth))+ ' %')
					
					END	   AS 'Auto Grow'  ,
					('Use ['+DB_NAME(tbl2.dbid)+']; DBCC SHRINKFILE (['+tbl2.name+'],' +CONVERT(NVARCHAR(10),UsedSize)+');') [truncate script]
											  	
FROM
		#tbl					AS tbl1
		,sys.sysaltfiles		AS tbl2
WHERE (tbl1.FILEPath = tbl2.filename)  AND (tbl1.FILENAME = tbl2.name)
--		AND	(DB_NAME(tbl2.dbid) IN ('CM_HST'))


ORDER BY FreeSpace DESC
DROP TABLE #tbl

--Use [Monitoring]; DBCC SHRINKFILE ([Monitoring],11223);



/*
EXEC sp_GetDataFilesUsage


USE	[RM]
go
DBCC SHRINKFILE (RM_Data, 5000)

USE	 [MDTicks]
go
DBCC SHRINKFILE (MDTicks_index, 94000)

USE [DSLogDB]
go
DBCC SHRINKFILE (DsLogDb_2, 6) 

USE [CD_HST]
go
DBCC SHRINKFILE (CD_HST_Data, 100000) 

Use [RMResult]; DBCC SHRINKFILE ([RMResult_Data],8248);

*/
