SELECT   (SELECT TOP 1 article from [distribution].dbo.MSarticles AS t2 WHERE article_id = t1.article_id), article_id,COUNT(*)
  FROM [distribution].[dbo].[MSrepl_commands]	AS t1 WITH (NOLOCK) 
  GROUP BY t1.article_id
  ORDER BY 1
  
  
  
