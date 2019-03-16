DECLARE @TSQL  NVARCHAR(2000)
DECLARE @lC    INT
CREATE TABLE #TempLog (
      LogDate     DATETIME,
      ProcessInfo NVARCHAR(50),
      [Text] NVARCHAR(MAX))
CREATE TABLE #logF (
      ArchiveNumber     INT,
      LogDate           DATETIME,
      LogSize           INT
)
INSERT INTO #logF   
EXEC sp_enumerrorlogs
SELECT @lC = MIN(ArchiveNumber) FROM #logF
WHILE @lC IS NOT NULL
BEGIN
      INSERT INTO #TempLog
      EXEC sp_readerrorlog @lC
      SELECT @lC = MIN(ArchiveNumber) FROM #logF 
      WHERE ArchiveNumber > @lC
  BREAK
END


declare @c varchar 
set @c = '''';

declare @c1 varchar 
set @c1 = '[';


SELECT LogDate,@@servername Server
,HOST=SUBSTRING (	Text,
						CHARINDEX('[',Text)+1,
						CHARINDEX(']',Text,CHARINDEX('[',Text)+1) - CHARINDEX('[',Text)-1
					)
,ObjectType=case
	when (Text like 'Logon failed for login%') then 'login'
			
	when (Text like 'Login failed for user%') then	'user'
end
,ObjectName=SUBSTRING (	Text,
						CHARINDEX(@c,Text)+1,
						CHARINDEX(@c,Text,CHARINDEX(@c,Text)+1) - CHARINDEX(@c,Text)-1
					)
,
Reason=
case
	when (Text like '%Reason%') then 
		SUBSTRING (	Text,
								CHARINDEX('.',Text)+1,
								CHARINDEX('.',Text,CHARINDEX('.',Text)+1) - CHARINDEX('.',Text)-1
							)
			
	else text
end
,Text
FROM #TempLog	
where ProcessInfo = 'Logon' 
and Text like '%failed%'
--AND Text LIKE '%sa%'
	   ORDER BY 1 desc

DROP TABLE #TempLog
DROP TABLE #logF

--Login failed for user 'DbAdmin'. Reason: Password did not match that for the login provided. 172.21.101.45]