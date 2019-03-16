SET TRAN ISOLATION LEVEL READ UNCOMMITTED
	 SELECT  
(SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id) AS db_name
 ,(SELECT TOP 1 (SELECT TOP 1 publication FROM [distribution].dbo.MSpublications WHERE publication_id =  t2.publication_id) from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id AND t2.publisher_db = (SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id)  )  AS Publication
	  
 ,(SELECT TOP 1 t11.article from [distribution].dbo.MSarticles AS t11 WHERE t11.article_id = t1.article_id AND t11.publisher_db = (SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id)  )  AS Article_name
   
 ,    COUNT(*) AS [cmd waiting]
 ,   t1.article_id
  FROM 
		[distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
		
	GROUP BY t1.article_id	,publisher_database_id
	ORDER BY 4 DESC 
	
SELECT COUNT(*),(SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id) AS db_name
FROM [distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) GROUP BY publisher_database_id
 
/*ERROR NAME*/
 SELECT TOP 100
 da.name,da.publication,da.publisher_db,
 dh.comments,dh.error_id,dh.time 
 FROM distribution.dbo.MSdistribution_history DH INNER JOIN distribution.dbo.MSdistribution_agents DA  ON
	DH.agent_id = DA.id	
	ORDER BY dh.time DESC
	
 SELECT TOP 100
 da.name,da.publication,da.publisher_db,
 dh.comments,dh.error_id,dh.time 
 FROM distribution.dbo.MSlogreader_history DH INNER JOIN distribution.dbo.MSlogreader_agents DA  ON
	DH.agent_id = DA.id	
	ORDER BY dh.time DESC		
/***/
SELECT TOP 6 * FROM distribution.dbo.MSrepl_errors	 ORDER BY 2 DESC
	

	--SELECT * FROM	[distribution].dbo.MSarticles ORDER BY article_id

	--		sp_browsereplcmds	@article_id = 64
								
/*
================================================================================================================================================================================
		   waiting commands per articals distt 1
================================================================================================================================================================================
 SELECT   t1.publisher_database_id	, t1.article_id,COUNT(*) AS [cmd waiting] ,(SELECT TOP 1 article from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id ) 
,		(SELECT TOP 1 (SELECT TOP 1 publication FROM [distribution].dbo.MSpublications WHERE publication_id = t2.publication_id) from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id )
  FROM 
		[distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
		
	GROUP BY t1.article_id	,publisher_database_id
	ORDER BY 2 desc
	
	SELECT * FROM	[distribution].dbo.MSarticles 
	
================================================================================================================================================================================
		   waiting commands per articals distt 2
================================================================================================================================================================================
SELECT    t1.article_id,COUNT(*) AS [cmd waiting] ,(SELECT TOP 1 article from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id ) 
,			(SELECT TOP 1 (SELECT TOP 1 publication FROM [distribution].dbo.MSpublications WHERE publication_id = t2.publication_id) from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id )
  FROM 
		[distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
		
	GROUP BY t1.article_id
	ORDER BY 2 desc
	-----------
		GO
	-----------
		SELECT article_id,* FROM	[distribution].dbo.MSarticles 
		order by 1 
	*/
  