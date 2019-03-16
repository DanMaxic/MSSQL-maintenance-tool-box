
EXEC [master].[dbo].[xp_ss_listfiles] @filename = 'C:\Data\TestAutomation.safe'
EXEC [master].[dbo].[xp_ss_restore] 
 @database = 'TestAutomation'
,@filename =  'C:\Data\TestAutomation.safe'

,@withmove = 'TestAutomation_Data	C:\Data\TestAutomation_Data.MDF'
--,@withmove = 'IRData2	B:\Data\RM\IR2.NDF'
,@withmove = 'TestAutomation_Log	C:\Data\TestAutomation_Log.LDF'
,@debug = 0
,@nostatus = 0
,@replace = 1
,@disconnectusers = 1
--,@recoverymode = 'norecovery'