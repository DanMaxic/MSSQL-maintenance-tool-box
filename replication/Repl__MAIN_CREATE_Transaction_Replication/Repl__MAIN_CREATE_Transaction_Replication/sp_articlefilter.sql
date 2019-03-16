
USE TR_ReplTest   --[DB NAME]
GO

DECLARE @PublicationName sysname
DECLARE @ArticleName sysname
DECLARE @FilterName sysname
DECLARE @FilterClause sysname


SELECT 
	@PublicationName	= N'TestPublication',    --'<Set Publication Name>'
	@ArticleName		= N'Test_1',             --'<Set article name>'  
	@FilterName			= N'FLTR_Test_1_1',      --'<Set Filter Name>'

	
--  @FilterClause		= N'c > 3' /*For Add filter*/
	@FilterClause		= NULL    /*For Delete/Remove filter*/


--------- Adding the article filter
exec sp_articlefilter 
	@publication			   = @PublicationName, 
	@article				   = @ArticleName, 
	@filter_name	           = @FilterName, 
	@filter_clause	           = @FilterClause,
	@force_invalidate_snapshot = 1,
	@force_reinit_subscription = 1
GO


/***************HELP*************************
SELECT * FROM sysarticles
SELECT * FROM sys.objects WHERE object_id = 1813581499
SELECT * FROM sys.objects WHERE parent_object_id =1141579105
SELECT * FROM sys.objects WHERE object_id = 1141579105
**********************************************/
