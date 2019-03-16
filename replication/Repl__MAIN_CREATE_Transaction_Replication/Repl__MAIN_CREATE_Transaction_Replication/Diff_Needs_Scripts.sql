

--Script to drop articles from transactional replication
USE distribution
GO
--DECLARE @str Varchar(1000)

SELECT 'USE ' + p.publisher_db + CHAR(13) + 'GO ' + CHAR(13) + 
'exec sp_dropsubscription @publication = ''' + p.publication + ''', @article = '''
        + a.article + ''', @subscriber = ''' + s.srvname
        + ''', @destination_db = ''' + sub.subscriber_db + '''' + CHAR(13)
        + 'exec sp_droparticle @publication = ''' + p.publication
        + ''', @article = ''' + a.article + '''' + CHAR(10) + CHAR(13)
FROM    dbo.mspublications p
        INNER JOIN dbo.msarticles a
            ON p.publication_id = a.publication_id
        INNER JOIN dbo.msdistribution_agents ag
            ON p.publisher_id = ag.publisher_id
               AND p.publisher_db = ag.publisher_db
        INNER JOIN master.dbo.sysservers s
            ON ag.subscriber_id = s.srvid
        INNER JOIN dbo.mssubscriptions sub
            ON ag.id = sub.agent_id
               AND sub.publisher_id = p.publisher_id
               AND sub.publisher_db = p.publisher_db
               AND sub.article_id = a.article_id
WHERE   
--a.article IN ( 'table1' , 'table2' , 'etc..' )
--AND 
p.publisher_db = 'ReplicationDB' 

-----------------------------------------------------
--USE ReplicationDB
--GO
--SELECT * FROM sysarticles
--SELECT * FROM syssabscriptions

/*
SELECT * from sysarticles
SELECT * from syssubscriptions WHERE artid IN ()
SELECT * from syspublications
EXEC sp_helpsubscription
EXEC sp_helppublication
*/