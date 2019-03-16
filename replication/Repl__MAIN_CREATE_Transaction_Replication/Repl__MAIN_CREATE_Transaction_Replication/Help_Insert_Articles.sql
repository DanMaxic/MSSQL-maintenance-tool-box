
 
 USE MM
 GO
 
 IF OBJECT_ID('Relp_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_TempArticleCollector
 GO
 
 
 SELECT  B.name AS PublicationName
        ,A.artid
        ,A.name AS ArticleName
        ,A.status
        ,C.srvname AS Subscriber
        ,A.filter_clause AS Filter
 INTO    dbo.Relp_TempArticleCollector
 FROM    dbo.sysarticles AS A
         INNER JOIN dbo.syspublications AS B
            ON A.pubid = B.pubid
         LEFT JOIN syssubscriptions AS C
            ON A.artid = C.artid
 ORDER BY PublicationName
        ,A.artid
GO   
   
 
 -----------------Create List Of Articles---------------

 USE MM
 GO
 
 IF OBJECT_ID('Relp_Distinct_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_Distinct_TempArticleCollector
 GO
 
 
 SELECT DISTINCT
         PublicationName
--,artid
        ,ArticleName
--,status
--,Subscriber
--,Filter
 INTO    dbo.Relp_Distinct_TempArticleCollector
 FROM    dbo.Relp_TempArticleCollector
 --WHERE  
 --status = 40
GO
 
 
 DECLARE @StringArticle VARCHAR(MAX)
  ,@PublicationName VARCHAR(80)
 
 SET @StringArticle = ''
 SET @PublicationName = 'MM'
 
 SELECT  @StringArticle = @StringArticle + ',''' + ArticleName + ''' '
 FROM    dbo.Relp_Distinct_TempArticleCollector
 WHERE   PublicationName = @PublicationName


----SELECT LEN(@StringArticle) 
SELECT @StringArticle = STUFF(@StringArticle,1,1,'')


 SELECT  @PublicationName AS 'PublicationName'
        ,@StringArticle AS 'ArtList'

GO




---------Delete Tables
 IF OBJECT_ID('Relp_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_TempArticleCollector
 GO
 IF OBJECT_ID('Relp_Distinct_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_Distinct_TempArticleCollector  --Relp_Distinct_TempArticleCollector
 GO







/*
List Of Art per Pub:


*/
