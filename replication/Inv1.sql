 
 
 --PENDING COMMANDS PER SUBSCRBER
 --
	 SELECT  t1.publisher_database_id,
(SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id) AS db_name
 ,(SELECT TOP 1 (SELECT TOP 1 publication FROM [distribution].dbo.MSpublications WHERE publication_id =  t2.publication_id) from [distribution].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id AND t2.publisher_db = (SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id)  )  AS Publication
	  
 ,(SELECT TOP 1 t11.article from [distribution].dbo.MSarticles AS t11 WHERE t11.article_id = t1.article_id AND t11.publisher_db = (SELECT publisher_db FROM distribution.dbo.MSpublisher_databases WHERE id =  t1.publisher_database_id)  )  AS Article_name
   
 ,    COUNT(*) AS [cmd waiting]
 ,   t1.article_id
  FROM 
		[distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
		
	GROUP BY t1.article_id	,publisher_database_id
	ORDER BY 5 DESC 
	
 
 	  SELECT top 1  [xact_seqno],count([xact_seqno])  FROM [distribution].[dbo].[MSrepl_commands]
	  WHERE publisher_database_id = 4 and article_id = 124
	   group BY [xact_seqno]
	  ORDER BY 2 DESC	
	
	--SELECT * FROM	[distribution2].dbo.MSarticles ORDER BY article_id
	  
	  SELECT cmds.[xact_seqno],count(*),trns.[entry_time] FROM
	  	[distribution].dbo.[MSrepl_commands] cmds 
		inner join [distribution].dbo.[MSrepl_transactions] trns on cmds.[xact_seqno] = trns.[xact_seqno]
	  WHERE cmds.publisher_database_id = 20 and cmds.article_id = 1
	   group BY cmds.[xact_seqno],trns.[entry_time]
	  ORDER BY 3 DESC	
	  
	  SELECT TOP 1 CAST(command AS NVARCHAR(4000)),* 
	  from [distribution].dbo.[MSrepl_commands] 
	  WHERE publisher_database_id = 4
	  ORDER BY command_id DESC
	  
	  
	   SELECT  
	   [xact_seqno],
	   * FROM	[distribution].dbo.[MSrepl_commands] 
	   WHERE xact_seqno = 0x000F578B0000276F001E
	   GROUP BY [xact_seqno];
		 /*Get tran info*/
	   SELECT TOP 2 * FROM [distribution].dbo.MSrepl_transactions
		WHERE xact_seqno = 0x000F578B0000276F001E
	  
	  
	  */
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
	
	SELECT  FROM	[distribution].dbo.MSarticles 
	
================================================================================================================================================================================
		   waiting commands per articals distt 2
================================================================================================================================================================================
SELECT    t1.article_id,COUNT(*) AS [cmd waiting] ,(SELECT TOP 1 article from [distribution2].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id ) 
,			(SELECT TOP 1 (SELECT TOP 1 publication FROM [distribution2].dbo.MSpublications WHERE publication_id = t2.publication_id) from [distribution2].dbo.MSarticles AS t2 WHERE t2.article_id = t1.article_id )
  FROM 
		[distribution2].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
		
	GROUP BY t1.article_id
	ORDER BY 2 desc
	-----------
		GO
	-----------
		SELECT article_id,* FROM	[distribution2].dbo.MSarticles 
		order by 1 
	*/
  