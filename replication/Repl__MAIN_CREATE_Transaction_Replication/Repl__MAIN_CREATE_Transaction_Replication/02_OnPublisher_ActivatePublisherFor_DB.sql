
/***********************Enable Pablisher*******************/
USE FI_MD
GO

EXEC sp_replicationdboption 
                @dbname = N'FI_MD' ----N'<DB Name>'
               ,@optname = N'publish'  
               ,@value = N'true'
GO