/*============================================================================
  File:     Transactions.sql

  Summary:  Examine transaction log usage

  Date:     March 2011

  SQL Server Versions:
		10.0.2531.00 (SS2008 SP1)
		9.00.4035.00 (SS2005 SP3)
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SELECT s_tst.[session_id],

   s_es.[login_name] AS [Login Name],s_es.host_name, s_es.program_name,s_es.status, 
   DB_NAME (s_tdt.database_id) AS [Database], s_er.wait_type, s_er.wait_time,s_er.wait_resource,
   s_tdt.[database_transaction_begin_time] AS [Begin Time],
   s_tdt.[database_transaction_log_record_count] AS [Log Records],
   s_tdt.[database_transaction_log_bytes_used]/ ( 1048576) AS [Log MBytes],
   s_tdt.[database_transaction_log_bytes_reserved]/1048576 AS [Log Rsvd],
   s_est.[text] AS [Last T-SQL Text],
   s_eqp.[query_plan] AS [Last Plan]
FROM sys.dm_tran_database_transactions s_tdt
   JOIN sys.dm_tran_session_transactions s_tst
      ON s_tst.[transaction_id] = s_tdt.[transaction_id]
   JOIN sys.[dm_exec_sessions] s_es
      ON s_es.[session_id] = s_tst.[session_id]
   JOIN sys.dm_exec_connections s_ec
      ON s_ec.[session_id] = s_tst.[session_id]
   LEFT OUTER JOIN sys.dm_exec_requests s_er
      ON s_er.[session_id] = s_tst.[session_id]
   CROSS APPLY sys.dm_exec_sql_text (s_ec.[most_recent_sql_handle]) AS s_est
   OUTER APPLY sys.dm_exec_query_plan (s_er.[plan_handle]) AS s_eqp
   where (s_tdt.[database_transaction_log_bytes_reserved]/1048576) > 1
ORDER BY [Begin Time] ASC;
GO 

