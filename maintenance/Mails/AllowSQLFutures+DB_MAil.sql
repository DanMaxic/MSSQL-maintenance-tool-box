exec sp_configure 'show advanced options',1

exec sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE WITH OVERRIDE
GO
exec sp_CONFIGURE 'show advanced', 0
GO
RECONFIGURE WITH OVERRIDE

GO




/* Config Account MAil*/
declare @server_name nvarchar(200) = 'Alert@' + @@servername
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'Account',
    @description = 'Mail account for administrative e-mail.',
    @email_address = 'Alert@sd.com',
    @display_name = @server_name,
    @mailserver_name = '172.21.103.11' ;
    
/* Config Profile MAil*/  
DECLARE @profileId INT ;

EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = 'profile',
       @description = 'Profile used for administrative mail.',
       @profile_id = @profileId OUTPUT ;


    

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'profile',
    @account_name = 'Account',
    @sequence_number = 1 ;
 
 
 EXEC MSDB..sp_send_dbmail @profile_name='Profile',
@recipients='OPSDBA@SDGM.COM',
@subject='Test message',
@body='This is the body of the test message.
Congrates Database Mail Received By you Successfully.'   


