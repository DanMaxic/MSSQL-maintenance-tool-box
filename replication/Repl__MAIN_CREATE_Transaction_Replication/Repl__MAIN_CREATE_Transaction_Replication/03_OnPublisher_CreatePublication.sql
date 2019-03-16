/******************************
Create publications 
Run this Script on Publisher server.

******************************/


USE FI_MD  --[<DB Name>]
GO


DECLARE  
	 @pub sysname
	,@publisher sysname
--	,@db sysname
--	,@sub_db sysname ;
--	,@ArticleName sysname
--	,@Id int

--DECLARE @Articles TABLE ( ArticleName sysname, Id int IDENTITY(1,1));
			     	   
SELECT   
	 @publisher = @@SERVERNAME
--	,@sub_db    = N'Publication'   --N'FX' 
	,@pub	    = N'FI_MD__NRT_OW_4'     --publication Name[DBNAME]:PublicationName
--	,@db	    = N'Publication'   --N''

--SET @ArticleName = 'Spot'			   -- SET Table Name


/**********************Adding publication*********************/
PRINT 'Adding publication'
DECLARE @Desc sysname; 
SELECT @Desc = N'Transactional publication of ' + @pub + ' database from Publisher ' + @publisher

exec sp_addpublication 
	 @publication				= @pub
	,@restricted				= N'false'
	,@sync_method				= N'native'
	,@repl_freq					= N'continuous'
	,@description				= @Desc
	,@status					= N'active'
	,@allow_push 				= N'true'
	,@allow_pull 				= N'true'
	,@allow_anonymous			= N'false'
	,@enabled_for_internet		= N'false'
	,@independent_agent			= N'true'
	,@immediate_sync			= N'false'
	,@allow_sync_tran			= N'false'
	,@autogen_sync_procs		= N'false'
	,@retention					= 336
	,@allow_queued_tran			= N'false'
	,@snapshot_in_defaultfolder = N'true'
	,@compress_snapshot			= N'false'
	,@ftp_port					= 21
	,@ftp_login					= N'anonymous'
	,@allow_dts					= N'false'
	,@allow_subscription_copy	= N'false'
	,@add_to_active_directory	= N'false' ;


EXEC sp_addpublication_snapshot 
	 @publication					= @pub
	,@frequency_type				= 4
	,@frequency_interval			= 1
	,@frequency_relative_interval	= 0
	,@frequency_recurrence_factor	= 1
	,@frequency_subday				= 1
	,@frequency_subday_interval 	= 0
	,@active_start_date				= 0
	,@active_end_date				= 0
	,@active_start_time_of_day		= 220800
	,@active_end_time_of_day		= 0 ;


--ROLLBACK TRAN

--DECLARE @ArticleName sysname, @Id int;
--DECLARE @Articles TABLE ( ArticleName sysname, Id int IDENTITY(1,1));
--SET @ArticleName = '<ArticleName>'


--INSERT INTO  @Articles ( ArticleName )
--SELECT NAME 
--FROM   Sysobjects
--WHERE TYPE = 'U' AND Category <> 2
--AND objectproperty (sysobjects.id, 'TableHasPrimaryKey') = 1 -- Elimiate tables with no PK
--AND name IN ('Spot' )
--ORDER BY [name];
--
--
--SELECT @ID=0
--	WHILE(1=1)
--	BEGIN		
--		SELECT TOP 1 @ArticleName = ArticleName, @ID = ID
--		FROM	@Articles WHERE	@ID < ID
--		ORDER BY ID;
--
--		IF @@ROWCOUNT < 1 BREAK;
--
--		PRINT @ArticleName


-- Adding the transactional articles
--		EXEC sp_addarticle 
--			 @publication			= @pub
--			,@article				= @ArticleName
--			,@source_owner			= N'dbo'
--			,@source_object			= @ArticleName
--			,@destination_table		= @ArticleName 
--			,@type					= N'logbased' 
--			,@creation_script		= null
--			,@description			= null 
--			,@pre_creation_cmd		= N'none'
--			,@schema_option			= 0x000000000803FFDF --0x00000000000081F3
--			,@status				= 8
--			,@vertical_partition	= N'false'
--			,@ins_cmd 				= N'SQL'
--			,@del_cmd 				= N'SQL'
--			,@upd_cmd 				= N'SQL'
--			,@filter				= null
--			,@sync_object			= null
--			,@auto_identity_range	= N'false' 
--			,@identityrangemanagementoption = 'manual'
--			,@filter_clause = N'[DataSourceId] <>1' ------new
--END
GO



/*
-- Adding the article filter
exec sp_articlefilter 
	@publication = N'Spot_Feed', 
	@article = N'Spot', 
	@filter_name = N'FLTR_Spot_NOT_1', 
	@filter_clause = N'[DataSourceId] <>1',
	@force_invalidate_snapshot = 1,
	@force_reinit_subscription = 1
GO
*/



