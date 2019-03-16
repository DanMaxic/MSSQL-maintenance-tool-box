/*Managing */
 SET TRAN ISOLATION LEVEL READ UNCOMMITTED	
	


/*Top 20 sysprocesses CPU */
SELECT  
spid,blocked,waittime,lastwaittype,DB_NAME(prc.dbid) DB,cpu,physical_io,program_name,hostname,open_tran,loginame,prc.cmd ,CONVERT(NVARCHAR(50),text) txt



 fROM sys.sysprocesses prc CROSS APPLY sys.dm_exec_sql_text(sql_handle)
 WHERE blocked <> 0
 
 
ORDER BY prc.cpu DESC

WAITFOR DELAY '00:00:02'
	
SELECT #tmp.spid, #tmp.cpu,u.cpu
,(select SUM(cpu) FROM sys.sysprocesses)  -(select SUM(cpu) FROM #tmp) , 
(u.cpu - #tmp.cpu) dif,(u.cpu - #tmp.cpu)*100/( (select SUM(cpu) FROM sys.sysprocesses) - (select SUM(cpu) FROM #tmp)) 
--, (u.cpu - #tmp.cpu) /( SUM(u.cpu) - SUM(#tmp.cpu))
 FROM #tmp	INNER JOIN sys.sysprocesses u ON #tmp.spid = u.spid
DROP TABLE #tmp
    
    
    

  /*

/*Who work on Temp DB*/
SELECT top 5 * 
FROM sys.dm_db_task_space_usage
ORDER BY (user_objects_alloc_page_count +
internal_objects_alloc_page_count) DESC


/*Locks*/
SELECT db_name(rsc_dbid),Object_name(rsc_objid,rsc_dbid),* FROM sys.syslockinfo
WHERE req_spid IN (101,128)


/*Jobs*/
SELECT * FROM msdb..sysjobs		--SQLAgent - TSQL JobStep (Job 0xD193C5910CBDE24E975E89A6608C16F0 : Step 1)                                                       
	  */
