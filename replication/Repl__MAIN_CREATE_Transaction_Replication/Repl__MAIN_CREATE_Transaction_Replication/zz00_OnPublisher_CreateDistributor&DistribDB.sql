--Configuring the Distributor Server and the Distribution Database
Use master
GO


/****************Declare the variables***************/
DECLARE @distributor as sysname;
DECLARE @distributorserver_msg as varchar(50);

/**************Get the default instance of the name of 
the server and use that as the Distributor****************/
SET @distributor = (SELECT CONVERT (sysname,SERVERPROPERTY('servername')))


/**********Set the name and then print the name of the Distributor server***********/
SET @distributorserver_msg = 'The name of the Distributor server:';
PRINT @distributorserver_msg + ' ' + @distributor

/**********************Add the Distributor*********************/
EXEC sp_adddistributor @distributor = @distributor;

/*************** Install the distribution database on the default directory
and use Windows Integrated Authentication***********************/
DECLARE @distributiondb as sysname;
SET @distributiondb ='distribution';
EXEC sp_adddistributiondb @database = @distributiondb , @security_mode = 1  --@securety_mode = 0 ---  SQL Server Authentication
GO

SELECT CONVERT (sysname, SERVERPROPERTY('servername'))


/*
sp_helpdb 'distribution'
 Select  * From sys.sysservers
 Select  * From distribution.dbo.MSpublisher_databases
 Select  * From msdb.dbo.MSdistributor
*/