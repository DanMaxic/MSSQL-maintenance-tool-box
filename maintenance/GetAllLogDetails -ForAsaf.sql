			 /*

SELECT   DB_Name(database_id)  ,
*
FROM sys.master_files	WHERE type = 1	
DBCC SQLPERF (LOGSPACE)

	*/
CREATE TABLE #tmptable
(
	DBname			nvarchar(128)
	,DBfile			NCHAR(1024)
	,[TotalLogsize(MB)]		DECIMAL
	,[LogSpaceUsed%]	DECIMAL
	,STATUS			INT	   
)
INSERT INTO #tmptable
        ( DBname ,
          [TotalLogsize(MB)] ,
          [LogSpaceUsed%] ,
          STATUS
        )
EXEC ('DBCC SQLPERF (LOGSPACE)')

ALTER TABLE #tmptable   ADD [FreeSpaceMB] AS    CONVERT  (INT,([TotalLogsize(MB)]*(100-[LogSpaceUsed%])/100))

SELECT 
		TB1.DBname,TB2.name,
			   (SELECT recovery_model_desc FROM sys.databases WHERE name = TB1.DBname)
		,TB2.physical_name,[TotalLogsize(MB)],([TotalLogsize(MB)]-[FreeSpaceMB])AS [UsedSize MB],[FreeSpaceMB],[LogSpaceUsed%] 
		,
			CASE	
							WHEN TB2.growth > 100 THEN	(SELECT	CONVERT(sysname, (growth/128))+ ' MB')
							ELSE					(SELECT	CONVERT(sysname, (growth))+ ' %')
					
					END	   AS 'Auto Grow',
		'Use ['+TB1.DBname+']; DBCC SHRINKFILE (['+TB2.name+'], 0);' AS [Shrink Code],
		'USE [master]
GO
ALTER DATABASE [' +TB1.DBname+ '] SET RECOVERY SIMPLE WITH NO_WAIT;
GO
BACKUP DATABASE ['+TB1.DBname+ '] TO  DISK = N''E:\TempBackup\'+TB1.DBname+ '.bak'' 
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10 ;
GO'+
'
Use ['+TB1.DBname+']; DBCC SHRINKFILE (['+TB2.name+'], 0);
go
'
 AS AlterDB_Backup

FROM
	 #tmptable			AS TB1,
	 sys.master_files	AS TB2
WHERE 
	(TB1.DBname =DB_NAME(TB2.database_id))
	AND
		(TB2.type = 1)		  
	
	ORDER BY 7 desc 

DROP TABLE #tmptable

--EXEC master.sys.xp_fixeddrives
/*DBCC SQLPERF (LOGSPACE)


Use [tempdb]; DBCC SHRINKFILE ([templog], 0);

*/

