/***************AddArticles2Publication********************************/

USE FI_MD
    --[<DB Name>]
GO

SET NOCOUNT ON

DECLARE @pub SYSNAME
  ,@publisher SYSNAME
--	,@db sysname
--	,@sub_db sysname ;
  ,@ArticleName SYSNAME
  ,@ArticleSchema NVARCHAR(50)
  ,@Id INT
  
DECLARE @Articles TABLE
   ( 
    ArticleSchema NVARCHAR(50)
   ,ArticleName SYSNAME
   ,Id INT IDENTITY(1 , 1)
   ) ;

			     	   
SELECT   @publisher = @@SERVERNAME
--		,@sub_db    = N'Publication'   --N'FX' 
        ,@pub = N'FI_MD__NRT_OW_4'
        --publication Name
--		,@db	    = N'Publication'   --N''


INSERT   INTO @Articles
         ( 
          ArticleSchema
         ,ArticleName 
         )
         SELECT   TABLE_SCHEMA
                 ,TABLE_NAME
         FROM     INFORMATION_SCHEMA.TABLE_CONSTRAINTS
         WHERE    CONSTRAINT_TYPE = 'PRIMARY KEY'
                  AND TABLE_NAME IN ( 'MD_Bonds_CutOffTime','MD_Bonds_Hst_CurrencyCutoffTime' )
         ORDER BY TABLE_NAME

SELECT   @ID = 0
WHILE( 1 = 1 )
   BEGIN		
      SELECT TOP 1
               @ArticleSchema = ArticleSchema
              ,@ArticleName = ArticleName
              ,@ID = ID
      FROM     @Articles
      WHERE    @ID < ID
      ORDER BY ID ;

      IF @@ROWCOUNT < 1 
         BREAK ;

      BEGIN TRY
-- Adding the transactional articles 2 Publisher
         EXEC sp_addarticle @publication = @pub , @article = @ArticleName ,
            @source_owner = @ArticleSchema  --N'dbo'
            , @source_object = @ArticleName ,
            @destination_table = @ArticleName , @type = N'logbased' ,
            @creation_script = NULL , @description = NULL ,
            @pre_creation_cmd = N'none' , @schema_option = 0x000000000803FFDF --0x00000000000081F3
            , @status = 8 , @vertical_partition = N'false' , @ins_cmd = N'SQL' ,
            @del_cmd = N'SQL' , @upd_cmd = N'SQL' , @filter = NULL ,
            @sync_object = NULL , @auto_identity_range = N'false' ,
            @identityrangemanagementoption = 'manual'
--			,@filter_clause = N'[DataSourceId] <>1' ------new

         PRINT 'The Article ' + '''' + @ArticleSchema + '.' + @ArticleName
            + '''' + ' was added to publication ' + '''' + @pub + ''''

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

/*
--sp_who2
DBCC INPUTBUFFER(57)
DBCC INPUTBUFFER(63)
KILL 63
SELECT * FROM sysarticles

*/