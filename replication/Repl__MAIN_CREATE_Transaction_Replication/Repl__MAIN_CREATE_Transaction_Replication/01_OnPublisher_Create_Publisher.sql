USE Master
GO


/*--------------------------------------------------------------
----------------Configuring the Publisher Server----------------
--------------------------------------------------------------*/

/* Declare the variables */
DECLARE @distributor AS SYSNAME ;
DECLARE @publisher AS SYSNAME ;
DECLARE @publisherserver_msg AS VARCHAR(50)


/*Get the default instance of the name of the server and
use that as the Distributor */
SET @distributor = ( SELECT   CONVERT (SYSNAME , SERVERPROPERTY('servername')) )

/*Set the name and then print the name of the Publisher server.
The Publisher and the Distributor are residing on the same server */
SET @publisher = @distributor ;
SET @publisherserver_msg = 'The name of the publisher server:'
PRINT @publisherserver_msg + ' ' + @publisher

/*Now add the Publisher to the same Distributor as
installed locally --- remember that sp_adddistpublisher can
be used for snapshot, transactional and merge replication*/
USE distribution
DECLARE @distributiondb AS SYSNAME ;
SET @distributiondb = 'distribution'
EXEC sp_adddistpublisher @publisher , @security_mode = 1 ,
   @distribution_db = @distributiondb , @publisher_type = 'MSSQLSERVER' ;
GO

/*
sp_helpdb 'distribution'
 Select  * From sys.sysservers
 Select  * From distribution.dbo.MSpublisher_databases
 Select  * From msdb.dbo.MSdistributor
 Select  * From distribution.dbo.IHpublications
 Select  * From distribution.dbo.MSpublications
 Select  * From distribution.dbo.IHpublishers

 Select  * From distribution.dbo.MSpublisher_databases

SELECT * from syspublications

Select* From distribution.dbo.MSdistribution_agents
Select* From distribution.dbo.MSsubscriber_info
Select* From distribution.dbo.MSsubscriptions
Select* From distribution.dbo.MSrepl_version
Select* From distribution.dbo.MSrepl_errors
Select* From distribution.dbo.MSlogreader_agents
*/


