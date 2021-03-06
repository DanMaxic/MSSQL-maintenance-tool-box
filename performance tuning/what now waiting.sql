SELECT 
	WT.session_id,
	exec_context_id,
	est.dbid,
	program_name,
	host_name,
	wait_duration_ms,
	ER.wait_type,
	WT.resource_address,
	ER.blocking_session_id,
	est.text,
	eqp.query_plan,
	es.cpu_time,
	es.memory_usage	

FROM 
	sys.dm_os_waiting_tasks		WT
	INNER JOIN 
	sys.dm_exec_sessions		ES 	ON WT.session_id = ES.session_id
	INNER JOIN 
	sys.dm_exec_requests		ER ON ES.session_id = ER.session_id
OUTER APPLY
	sys.dm_exec_sql_text(ER.sql_handle) est
OUTER APPLY 
	sys.dm_exec_query_plan(er.plan_handle) eqp
WHERE ES.is_user_process = 1
ORDER BY 1   ,wt.exec_context_id