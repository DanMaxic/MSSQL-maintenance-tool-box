USE CRM 
GO

select distinct p.name,a.name from sysarticles a
inner join syspublications p on a.pubid = p.pubid 
where a.name like 'UserSuccessfulLoginsConfig%'
order by 1 

go

SET NOCOUNT ON ;

IF EXISTS ( SELECT   1
            FROM     Tempdb..Sysobjects
            WHERE    [Id] = OBJECT_ID('Tempdb..#Repl_PublisherSubscriber') ) 
   BEGIN
      DROP TABLE  #Repl_PublisherSubscriber
   END

--- Correction for One Way Subscription   
IF EXISTS ( SELECT   1
            FROM     Tempdb..Sysobjects
            WHERE    [Id] = OBJECT_ID('Tempdb..#Repl_Subscriber') ) 
   BEGIN
      DROP TABLE  #Repl_Subscriber
   END
   
CREATE TABLE #Repl_Subscriber ( Subscriber VARCHAR(50) )
      
CREATE TABLE #Repl_PublisherSubscriber
   ( 
    Publisher VARCHAR(50)
   ,Subscriber VARCHAR(50)
   ,Is_ActiveSubscr TINYINT
   )

DECLARE @PublicationName VARCHAR(80)
  ,@PublisherSrv VARCHAR(80)
  ,@dbName VARCHAR(80)
  ,@Subscribtion_DB VARCHAR(80)
  ,@FilterName VARCHAR(80)
  ,@FilterClause VARCHAR(250)
  ,@FilterConstant VARCHAR(250)
  ,@SubscriberSrv VARCHAR(80)
  ,@Is_Publisher BIT
  ,@Is_dbName BIT
  ,@Is_PublicationName BIT
  ,@ArticleController BIT
  ,@artList_1 VARCHAR(120)
  ,@artList_2 VARCHAR(120)
  ,@artList_3 VARCHAR(120)
  ,@artList_4 VARCHAR(120) 

/***  Impute Variables ***/
SET @dbName = N'IR'
SET @PublicationName = N'IR__NRT_TW_4'
SET @Subscribtion_DB = N'IR'

SET @artList_1 = 'App_Countries'
SET @artList_2 = 'DataX_BondFuturePhrases'
SET @artList_3 = 'DataX_BondFutures'
set @artList_4 = ''
-------------------

SET @PublisherSrv = @@SERVERNAME

--False = 0  
SET @Is_Publisher = 0
SET @Is_dbName = 0
SET @Is_PublicationName = 0


--- Correction for One Way Subscription   
INSERT   INTO #Repl_Subscriber
         SELECT DISTINCT
                  C.srvname AS Subscriber
         FROM     dbo.sysarticles AS A
                  INNER JOIN dbo.syspublications AS B
                     ON A.pubid = B.pubid
                  LEFT JOIN syssubscriptions AS C
                     ON A.artid = C.artid
         WHERE    B.name = @PublicationName

INSERT   INTO #Repl_PublisherSubscriber
         SELECT DISTINCT
                  @@SERVERNAME
                 ,srvname
                 ,'1'
         FROM     dbo.syssubscriptions
         WHERE    dest_db = @Subscribtion_DB
                  AND srvname IN ( SELECT Subscriber
                                   FROM   #Repl_Subscriber )


-----List of Subscribers
--SELECT   Publisher
--        ,Subscriber
--        ,Is_ActiveSubscr
--FROM     #Repl_PublisherSubscriber        
---------------

PRINT 'Pay Attention !!! This is 2HUB Replication Topology.There are Main Servers On UK AND NJ.'
PRINT 'This action MUST refer for both ( UK AND NJ ) environments.'
PRINT CHAR(13)

  
--- Is Pablisher 
IF EXISTS ( SELECT   1
            FROM     #Repl_PublisherSubscriber
            WHERE    Publisher = @PublisherSrv
                     AND Is_ActiveSubscr = 1 ) 
   BEGIN         
      SET @Is_Publisher = 1         
   END
   
   
--- Is Right DB 
IF ( DB_NAME() = @dbName ) 
   BEGIN
      SET @Is_dbName = 1
   END     

--- Is Right PublicationName
IF OBJECT_ID('syspublications') IS NOT NULL 
   BEGIN
      IF EXISTS ( SELECT   1
                  FROM     dbo.syspublications
                  WHERE    name = @PublicationName ) 
         BEGIN 
            SET @Is_PublicationName = 1
         END
   END 
         
IF ( @Is_Publisher = 1
     AND @Is_dbName = 1
     AND @Is_PublicationName = 1 ) 
   BEGIN --------Start IF   
      DECLARE @ArticleName VARCHAR(80)
        ,@Id INT ;
  
      DECLARE @Articles TABLE
         ( 
          ArticleName VARCHAR(80)
         ,Id INT IDENTITY(1 , 1)
         )

      INSERT   INTO @Articles ( ArticleName )
               SELECT   NAME
               FROM     sys.objects
               WHERE    TYPE = 'U'
                  --AND Category <> 2
                        AND OBJECTPROPERTY(object_id , 'TableHasPrimaryKey') = 1
                        AND name IN ( @artList_1 , @artList_2 , @artList_3 , @artList_4 )
                                      
      SET @ArticleController = 0
   
      DECLARE Curr_AddArtSubscr CURSOR
         FOR SELECT  Subscriber
             FROM    #Repl_PublisherSubscriber
             WHERE   Publisher = @PublisherSrv
                    AND Is_ActiveSubscr = 1                      
      OPEN Curr_AddArtSubscr
      FETCH NEXT FROM Curr_AddArtSubscr INTO @SubscriberSrv
      WHILE ( @@fetch_status = 0 )
         BEGIN
            BEGIN TRY         
               SELECT   @ID = 0
               WHILE( 1 = 1 )
                  BEGIN         
                     SELECT TOP 1
                              @ArticleName = ArticleName
                             ,@ID = ID
                     FROM     @Articles
                     WHERE    @ID < ID
                     ORDER BY ID ;

                     IF @@ROWCOUNT < 1 
                        BREAK ;
                     IF ( @ArticleController = 0 ) 
                        BEGIN                                                      
                           
/*  Adding the articles  */
                           EXEC sp_addarticle @publication = @PublicationName ,
                              @article = @ArticleName , @source_owner = N'dbo' ,
                              @source_object = @ArticleName ,
                              @destination_table = @ArticleName ,
                              @type = N'logbased' , @creation_script = NULL ,
                              @description = NULL ,
                              @pre_creation_cmd = N'none' ,
                              @schema_option = 0x000000000803FFDF ,
                              @status = 8 , @vertical_partition = N'false' ,
                              @ins_cmd = N'SQL' , @del_cmd = N'SQL' ,
                              @upd_cmd = N'SQL' , @filter = NULL ,
                              @sync_object = NULL ,
                              @auto_identity_range = N'false' ,
                              @identityrangemanagementoption = 'manual' ;            

/* Add articles to subscribtions  */
                           EXEC sp_addsubscription @publication = @PublicationName ,
                              @subscriber = @SubscriberSrv ,
                              @destination_db = @Subscribtion_DB ,
                              @subscription_type = N'Pull' ,
                              @sync_type = N'none' , @article = @ArticleName ,
                              @update_mode = N'read only' ,
                              @subscriber_type = 0

                           PRINT 'Add_Article : ' + @ArticleName
                              + '; Subscriber: ' + @SubscriberSrv                     
                           PRINT 'Add_Subscription for article: '
                              + @ArticleName + '; Subscriber: '
                              + @SubscriberSrv                     
                           PRINT CHAR(13)                           
                           
                        END 
                     IF ( @ArticleController = 1 ) 
                        BEGIN                                              
 /* Add articles to subscribtions  */
                           EXEC sp_addsubscription @publication = @PublicationName ,
                              @subscriber = @SubscriberSrv ,
                              @destination_db = @Subscribtion_DB ,
                              @subscription_type = N'Pull' ,
                              @sync_type = N'none' , @article = @ArticleName ,
                              @update_mode = N'read only' ,
                              @subscriber_type = 0
         
                           PRINT 'Add_Subscription for article: '
                              + @ArticleName + ' ; Subscriber: '
                              + @SubscriberSrv         
                        END                   
                  END                           
            END TRY
                       
            BEGIN CATCH
               PRINT '--- Error: ' + ERROR_MESSAGE() + '---'
                       
--PRINT 'OpenTranCount = ' + CAST(@@TRANCOUNT AS VARCHAR(5)) 
--PRINT @SubscriberSrv                      
               IF ( @@TRANCOUNT > 0 ) 
                  ROLLBACK
                                           
            END CATCH
            
            IF ( @ArticleController = 0 ) 
               SET @ArticleController = 1
            
            FETCH NEXT FROM Curr_AddArtSubscr INTO @SubscriberSrv
         END
          
      CLOSE Curr_AddArtSubscr
      DEALLOCATE Curr_AddArtSubscr
      
      PRINT CHAR(13)
      PRINT 'OpenTranCount = ' + CAST(@@TRANCOUNT AS VARCHAR(5))
   END -------End If
ELSE 
   BEGIN 
      PRINT 'The Incorrect One of Follow Parameters : PublisherSrv , PublicationName ,DataBaseName OR syspublications Table not exists.'  
      PRINT 'Please Check.'
   END

GO










