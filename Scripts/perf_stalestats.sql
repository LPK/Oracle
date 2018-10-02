-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_stalestats.sql                                             |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To find stale statistics for SQL_ID     			|
-- |                                                 		     		|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

alter session set nls_date_format='DD-MON-RR HH24:MI';

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

ACCEPT sql_id CHAR PROMPT 'Enter value for SQL_ID : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Stale Statistics                                            |
PROMPT | Instance : &current_instance                                           |
PROMPT | SQL_ID   : &sql_id							|
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    194
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN wait_class        FORMAT a26        	HEAD 'Wait Class'
COLUMN username          FORMAT a18        	HEAD 'User Name'
COLUMN INST_ID		    FORMAT 999999   
COLUMN MACHINE		    FORMAT a20
COLUMN INST_ID		    FORMAT 999999 
COLUMN LOGON_TIME	    FORMAT a20		HEAD 'Logon Time'
COLUMN OSUSER 		    FORMAT a18		HEAD 'OS User'
COLUMN TERMINAL		    FORMAT a15
COLUMN SESS_ID		    FORMAT a10		HEAD 'SESSION ID'
COLUMN OBJECT		    FORMAT a20		HEAD 'OBJECT NAME'
COLUMN TERMINAL		    FORMAT a15
COLUMN OBJECT_OWNER	    FORMAT a16    	HEAD 'OWNER'
COLUMN FQ_NAME 					noprint
COLUMN STALE_STATS	FORMAT a12		HEAD 'Stale Stats'
COLUMN STATTYPE_LOCKED	FORMAT a12		HEAD 'Stat Locked'


select 
	distinct(OBJECT_OWNER||'.'||OBJECT_NAME) FQ_NAME
	, a.sql_id
	, object_owner
	,b.object_type
	, OBJECT_NAME, 
	b.LAST_ANALYZED, 
	b.num_rows, 
	b.STALE_STATS
	,b.stattype_locked 
from 
	gv$sql_plan a, 
	dba_tab_statistics b 
where 
	a.object_name=b.table_name
	and b.object_type='TABLE' 
and a.objecT_owner=b.owner
	and a.sql_id='&sql_id'
/

