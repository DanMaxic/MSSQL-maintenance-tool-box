
--Configuring the Distributor Server and the Distribution Database
USE master
GO
 

/****************Declare the variables***************/
DECLARE @DistributorName VARCHAR(50)
  ,@DistributorServer_msg VARCHAR(50)
  ,@DistributiondbName VARCHAR(50)
  ,@Is_LocalDistributor BIT
  ,@DataLocation nvarchar(255)
  ,@LogLocation nvarchar(255)


/*** Local Distributor  ***/   
SET @Is_LocalDistributor = 1
 --1  
-- @Is_LocalDistributor = 0 : Remove  Distributor
-- @Is_LocalDistributor = 1 : Local  Distributor

/***  Location Of MDF and LDF files of Distribution Data Base  ***/



/*** Set Name of Distributor ***/
SET @DistributorName = NULL
 

/*** Set Name of Distribution Data Base Name ***/
SET @DistributiondbName = 'distribution'

/***  Location Of MDF and LDF files of Distribution Data Base  ***/
SET @DataLocation = '...' --- Set Path
SET @LogLocation = '...'  --- Set Path

IF ( @Is_LocalDistributor = 1 ) 
   BEGIN

/*** Set Name of Distributor ***/
      SET @DistributorName = @@SERVERNAME

/*** Print Distributor server ***/
      SET @DistributorServer_msg = 'LOCAL Distributor Server: ' ;
      PRINT @DistributorServer_msg + ' ' + @DistributorName

/*** Add the Distributor ***/
      EXEC sp_adddistributor @distributor = @DistributorName ;

/*** Install the distribution database on the default directory 
     and use Windows Integrated Authentication***/    
      EXEC sp_adddistributiondb @database = @DistributiondbName ,
         @data_folder = @DataLocation , @log_folder = @LogLocation ,
         @security_mode = 1
  
/*** Set the name and then print the name of the Distributor server ***/
      SET @DistributorServer_msg = 'Distributor DataBase:' ;
      PRINT @DistributorServer_msg + ' ' + @DistributiondbName  
   END
ELSE 
   IF ( @Is_LocalDistributor = 0
        AND @DistributorName <> @@SERVERNAME
        AND @DistributorName IS NOT NULL ) 
      BEGIN

/*** Print Distributor server ***/
         PRINT 'This is Remote Distributor.For this reason RUN THIS Script on PUBLISHER SERVER to!!!'
         SET @DistributorServer_msg = 'Remote Distributor Server: ' ;
         PRINT @DistributorServer_msg + ' ' + @DistributorName

/*** Add the Distributor ***/
         EXEC sp_adddistributor @distributor = @DistributorName ;

/*** Install the distribution database on the default directory 
     and use Windows Integrated Authentication***/    
         EXEC sp_adddistributiondb @database = @DistributiondbName ,
            @security_mode = 1
  
/*** Set the name and then print the name of the Distributor server ***/
         SET @DistributorServer_msg = 'Distributor DataBase:' ;
         PRINT @DistributorServer_msg + ' ' + @DistributiondbName  

      END
   ELSE 
      BEGIN 
         SET @DistributorServer_msg = 'Remove Distributor Server NOT defined!!! ' ;
         PRINT @DistributorServer_msg 
      END

GO


-------------------------------------



/*

sp_helpdb 'distribution'
 Select  * From sys.sysservers
 Select  * From distribution.dbo.MSpublisher_databases
 Select  * From msdb.dbo.MSdistributor
*/