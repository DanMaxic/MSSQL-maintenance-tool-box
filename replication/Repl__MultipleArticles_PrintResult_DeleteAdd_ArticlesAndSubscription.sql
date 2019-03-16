
 --Set Data base name
USE FXMD
GO

/*
--- Additional Variant for select statmnet creating:
EXEC distribution.dbo.Add_Delete_SubscriptionArticles_prc 'FXMD','Forwards','Butterflies'
*/

PRINT CHAR(10)
PRINT '--- Server Name: ' + @@SERVERNAME
PRINT CHAR(10)

SET NOCOUNT ON ;
DECLARE @publisher_db VARCHAR(120)
  ,@artList_1 VARCHAR(120)
  ,@artList_2 VARCHAR(120)
  ,@artList_3 VARCHAR(120)
  ,@SQLSTR NVARCHAR(4000)
  ,@Publication VARCHAR(120)
  ,@ArticleName VARCHAR(120)
  ,@filter_name VARCHAR(120)
  ,@filter_clause VARCHAR(500)
  ,@SubscribetServer VARCHAR(120)
  ,@dest_db VARCHAR(120)


------- Set variables:
SET @publisher_db = 'FXMD'
SET @artList_1 = ''
SET @artList_2 = 'Butterflies10'
SET @artList_3 = ''
-------------------



PRINT '------------------------- Drop Article Part ------------------------------'
PRINT '--- DROP Subscriptions ---'
DECLARE Curr_DropSubscription CURSOR LOCAL
   FOR SELECT  B.name
              ,A.name
              ,C.srvname
              ,C.dest_db
       FROM    dbo.sysarticles AS A
               INNER JOIN dbo.syspublications AS B
                  ON A.pubid = B.pubid
               INNER JOIN dbo.syssubscriptions AS C
                  ON A.artid = C.artid
       WHERE   A.name IN ( @artList_1 , @artList_2 , @artList_3 )
       ORDER BY A.name
                
OPEN Curr_DropSubscription    
FETCH NEXT FROM Curr_DropSubscription INTO @Publication , @ArticleName ,
   @SubscribetServer , @dest_db
WHILE ( @@fetch_status = 0 )    
   BEGIN    
      BEGIN TRY    
         
         SELECT   @SQLSTR = N' USE ' + QUOTENAME(@publisher_db)
                  + ' EXEC sp_dropsubscription ' + ' @publication = N' + ''''
                  + @Publication + '''' + ',@article = ' + '''' + @ArticleName
                  + '''' + ',@subscriber = ' + '''' + @SubscribetServer + ''''
                  + ',@destination_db = ' + '''' + @dest_db + '''' --+  CHAR(10)                 
         PRINT @SQLSTR                               
      END TRY    
          
      BEGIN CATCH                   
         SELECT   ERROR_MESSAGE() AS DropSubscription_ErrorMessage  

      END CATCH    
        
         
      FETCH NEXT FROM Curr_DropSubscription INTO @Publication , @ArticleName ,
         @SubscribetServer , @dest_db
   END    
              
CLOSE Curr_DropSubscription    
DEALLOCATE Curr_DropSubscription  

/*----------------------------------------------------------------*/
PRINT CHAR(10) + '--- DROP Articles ---'
 --+ CHAR(10)

DECLARE Curr_DropArticle CURSOR LOCAL
   FOR SELECT DISTINCT
               B.name
              ,A.name
       FROM    dbo.sysarticles AS A
               INNER JOIN dbo.syspublications AS B
                  ON A.pubid = B.pubid
               INNER JOIN dbo.syssubscriptions AS C
                  ON A.artid = C.artid
       WHERE   A.name IN ( @artList_1 , @artList_2 , @artList_3 )
       ORDER BY A.name
                
OPEN Curr_DropArticle    
FETCH NEXT FROM Curr_DropArticle INTO @Publication , @ArticleName
  --, @SubscribetServer , @dest_db
WHILE ( @@fetch_status = 0 )    
   BEGIN    
      BEGIN TRY    
         
         SELECT   @SQLSTR = N'USE ' + QUOTENAME(@publisher_db)
                  + ' EXEC sp_droparticle ' + ' @publication = N' + ''''
                  + @Publication + '''' + ',@article = ' + '''' + @ArticleName
                  + ''''                                  
         PRINT @SQLSTR                                  
      END TRY              
      BEGIN CATCH                   
         SELECT   ERROR_MESSAGE() AS Curr_DropArticle_ErrorMessage  
      END CATCH                     
      FETCH NEXT FROM Curr_DropArticle INTO @Publication , @ArticleName  --, @SubscribetServer , @dest_db
   END    
              
CLOSE Curr_DropArticle    
DEALLOCATE Curr_DropArticle  

PRINT CHAR(10)
PRINT '------------------------ Add Article Part --------------------------------'

PRINT '--- ADD_ArticlesToPublication ---'
DECLARE Curr_ArticlesToPublication CURSOR LOCAL
   FOR SELECT DISTINCT
               B.name
              ,A.name
       FROM    dbo.sysarticles AS A
               INNER JOIN dbo.syspublications AS B
                  ON A.pubid = B.pubid
               INNER JOIN dbo.syssubscriptions AS C
                  ON A.artid = C.artid
       WHERE   A.name IN ( @artList_1 , @artList_2 , @artList_3 )
       ORDER BY A.name
                
OPEN Curr_ArticlesToPublication    
FETCH NEXT FROM Curr_ArticlesToPublication INTO @Publication , @ArticleName
 -- ,
   --@SubscribetServer , @dest_db
WHILE ( @@fetch_status = 0 )    
   BEGIN    
      BEGIN TRY                
         SELECT   @SQLSTR = N'USE ' + QUOTENAME(@publisher_db)
                  + 'EXEC sp_addarticle @publication = ''' + @Publication
                  + '''' + ' ,@article = ''' + @ArticleName + ''''
                  + ' ,@source_owner = N''' + 'dbo' + ''''
                  + ' ,@source_object = ''' + @ArticleName + ''''
                  + ' ,@destination_table = ''' + @ArticleName + ''''
                  + ' ,@type = N''' + 'logbased' + ''''
                  + ' ,@creation_script = null' + ' ,@description = null'
                  + ' ,@pre_creation_cmd = N''' + 'none' + ''''
                  + ' ,@schema_option = 0x000000000803FFDF' + ' ,@status = 8'
                  + ' ,@vertical_partition = N''' + 'false' + ''''
                  + ' ,@ins_cmd = N''' + 'SQL' + '''' + ' ,@del_cmd = N'''
                  + 'SQL' + '''' + ' ,@upd_cmd = N''' + 'SQL' + ''''
                  + ' ,@filter	 = null' + ' ,@sync_object = null'
                  + ' ,@auto_identity_range = N''' + 'false' + ''''
                  + ' ,@identityrangemanagementoption = N''' + 'manual' + ''''      


         PRINT @SQLSTR

          
      END TRY              
      BEGIN CATCH                   
         SELECT   ERROR_MESSAGE() AS Curr_ArticlesToPublication_ErrorMessage  
      END CATCH                     

                      
      FETCH NEXT FROM Curr_ArticlesToPublication INTO @Publication ,
         @ArticleName -- , @SubscribetServer , @dest_db
   END                  
CLOSE Curr_ArticlesToPublication    
DEALLOCATE Curr_ArticlesToPublication  



/*-----------------------------------------------------------------*/
PRINT CHAR(10) + '--- ADD_FilterToArticles ---'

IF EXISTS ( SELECT   1
            FROM     Tempdb..Sysobjects
            WHERE    [Id] = OBJECT_ID('Tempdb..#FilteredArticles') ) 
   BEGIN
      DROP TABLE  #FilteredArticles
   END
   
CREATE TABLE #FilteredArticles
   ( 
    publication VARCHAR(100)
   ,article VARCHAR(120)
   ,filter_name VARCHAR(120)
   ,filter_clause VARCHAR(500)
   )   

--SELECT * FROM #FilteredArticles


SET @SQLSTR = 'USE ' + @publisher_db + +' SELECT C.name AS publication 
,A.name AS article
,B.name AS filter_name
,A.filter_clause 
FROM     dbo.sysarticles AS A
         INNER JOIN sys.objects AS B
            ON A.filter = B.object_id
         INNER JOIN dbo.syspublications AS C
            ON C.pubid = A.pubid  
WHERE    A.name IN (''' + @artList_1 + ''',''' + @artList_2 + '''' + ','''
   + @artList_3 + '''' + ')'
   
----PRINT '---   TESTTTTTT'
----PRINT  @SQLSTR  

INSERT   INTO #FilteredArticles
         EXEC sp_executesql @SQLSTR


DECLARE Curr_AddFilterToArticles CURSOR LOCAL
   FOR SELECT DISTINCT
               publication
              ,article
              ,filter_name
              ,filter_clause
       FROM    #FilteredArticles
                
OPEN Curr_AddFilterToArticles    
FETCH NEXT FROM Curr_AddFilterToArticles INTO @Publication , @ArticleName ,
   @filter_name , @filter_clause 
WHILE ( @@fetch_status = 0 )    
   BEGIN    
      BEGIN TRY             
         SET @SQLSTR = 'USE ' + @publisher_db
            + ' EXEC sp_articlefilter @publication = ''' + @Publication + ''''
            + ' ,@article = ''' + @ArticleName + '''' + ' ,@filter_name = '''
            + @filter_name + '''' + ' ,@filter_clause = ''' + @filter_clause
            + ''''
            + ' , @force_invalidate_snapshot = 1 , @force_reinit_subscription = 1 '   
            
            
         PRINT @SQLSTR      
      END TRY              
      BEGIN CATCH                   
         SELECT   ERROR_MESSAGE() AS Curr_ArticlesToPublication_ErrorMessage  
      END CATCH                     
                      
      FETCH NEXT FROM Curr_AddFilterToArticles INTO @Publication ,
         @ArticleName , @filter_name , @filter_clause 
   END                  
CLOSE Curr_AddFilterToArticles    
DEALLOCATE Curr_AddFilterToArticles  


PRINT CHAR(10)
PRINT '--- ADD_SubscriptionToPublished_Articles ---'
DECLARE Curr_AddSubscription CURSOR LOCAL
   FOR SELECT  B.name
              ,A.name
              ,C.srvname
              ,C.dest_db
       FROM    dbo.sysarticles AS A
               INNER JOIN dbo.syspublications AS B
                  ON A.pubid = B.pubid
               INNER JOIN dbo.syssubscriptions AS C
                  ON A.artid = C.artid
       WHERE   A.name IN ( @artList_1 , @artList_2 , @artList_3 )
       ORDER BY A.name
                
OPEN Curr_AddSubscription    
FETCH NEXT FROM Curr_AddSubscription INTO @Publication , @ArticleName ,
   @SubscribetServer , @dest_db
WHILE ( @@fetch_status = 0 )    
   BEGIN    
      BEGIN TRY    
         
         SELECT   @SQLSTR = N'USE ' + QUOTENAME(@publisher_db)
                  + 'EXEC sp_addsubscription' + '  @publication = '''
                  + @Publication + '''' + ' ,@subscriber = '''
                  + @SubscribetServer + '''' + ' ,@destination_db = '''
                  + @dest_db + '''' + ' ,@subscription_type = N''' + 'Pull'
                  + '''' + ' ,@sync_type = N''' + 'none' + ''''
                  + ' ,@article = ''' + @ArticleName + ''''
                  + ' ,@update_mode = N''' + 'read only' + ''''
                  + ' ,@subscriber_type  = 0' + ' ,@subscriptionstreams  = 4'
                                                 
         PRINT @SQLSTR                                         
      END TRY              
      BEGIN CATCH                   
         SELECT   ERROR_MESSAGE() AS ADDSubscription_ErrorMessage  

      END CATCH    
                 
      FETCH NEXT FROM Curr_AddSubscription INTO @Publication , @ArticleName ,
         @SubscribetServer , @dest_db
   END    
              
CLOSE Curr_AddSubscription    
DEALLOCATE Curr_AddSubscription  


PRINT CHAR(10)
PRINT '-- OpenTranCount = ' + CAST(@@TRANCOUNT AS VARCHAR(5)) 

