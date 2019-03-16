
USE FI_MD
  ---[<DB Name>]
GO

-- FX_Main_One_Way
-----------------BEGIN: Script to be run at Publisher Server-----------------

DECLARE @pub sysname
  ,@ArticleName sysname
  ,@dest_db sysname
  ,@sub sysname
  ,@Id int
DECLARE @Articles TABLE
   ( 
    ArticleName sysname
   ,Id int IDENTITY(1 , 1)
   )



SELECT   
--	 @dest_db = N'destination_db'
         @dest_db = N'FI_MD'  --N'destination_db (DB ON Subscraber)'
        ,@pub = N'FI_MD__NRT_OW_4'	            --N'<Publication__Name>'	
	 
		--,@sub      = N'IREQ-SQL-SL-UK'         --N'<Subscriber Server Name>'
		--,@sub       = N'IREQ-SQL-PR-UK'
		,@sub      = N'IREQ-SQL-PR-SNG'
		--,@sub      = N'IREQ-SQL-PR-NJ'
		--,@sub      = N'IREQ-SQL-SL-NJ'
		
		--,@sub      = N'FX-SQL-PR-UK'
		--,@sub      = N'FX-SQL-PR-NJ'
		--,@sub      = N'FX-SQL-SL-UK'
		--,@sub      = N'FX-SQL-SL-NJ'

--	,@ArticleName = N'CashReceipt'



INSERT   INTO @Articles ( ArticleName )
         SELECT   TABLE_NAME
         FROM     INFORMATION_SCHEMA.TABLE_CONSTRAINTS
         WHERE    CONSTRAINT_TYPE = 'PRIMARY KEY'
                 AND TABLE_NAME IN ( 'MD_Bonds_CutOffTime','MD_Bonds_Hst_CurrencyCutoffTime' )
         ORDER BY TABLE_NAME




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

      BEGIN TRY
--			PRINT @ArticleName
         EXEC sp_addsubscription @publication = @pub , @subscriber = @sub ,
            @destination_db = @dest_db , @subscription_type = N'Pull' ,
            @sync_type = N'none' --N'replication support only'
            , @article = @ArticleName , @update_mode = N'read only' ,
            @subscriber_type = 0  --need check!!!
--				,@loopback_detection	    = N'true'
            , @subscriptionstreams = 4

         PRINT 'The Article ' + '''' + @ArticleName + ''''
            + ' was added to Subscription ' + '''' + @sub + ''''

      END TRY
      BEGIN CATCH
         PRINT 'Error Detected'
         SELECT   ERROR_NUMBER() ERNumber
                 ,ERROR_SEVERITY() Error_Severity
                 ,ERROR_STATE() Error_State
                 ,ERROR_PROCEDURE() Error_Procedure
                 ,ERROR_LINE() Error_Line
                 ,ERROR_MESSAGE() Error_Message
      END CATCH
   END
GO


-----------------END: Script to be run at Publisher Server-----------------

/*
SELECT * from distribution..syssubscriptions
SELECT * from syssubscriptions WHERE artid IN ()
SELECT * from sysarticles

*/