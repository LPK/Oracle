-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_phv_active.sql                                             |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To find execution statistics that is currently running		|
-- |                                                 		     		|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

ACCEPT sql_id CHAR PROMPT 'Enter value for SQL_ID : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Execution Statistics for Active SQL_ID                      |
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

COLUMN wait_class   	FORMAT a26        	HEAD 'Wait Class'
COLUMN username         FORMAT a18        	HEAD 'User Name'
COLUMN INST_ID		FORMAT 999999   
COLUMN MACHINE		FORMAT a20
COLUMN INST_ID		FORMAT 999999 
COLUMN LOGON_TIME	FORMAT a20		HEAD 'Logon Time'
COLUMN OSUSER 		FORMAT a18		HEAD 'OS User'
COLUMN TERMINAL		FORMAT a15
COLUMN SESS_ID		FORMAT a10		HEAD 'SESSION ID'
COLUMN OBJECT		FORMAT a20		HEAD 'OBJECT NAME'
COLUMN TERMINAL		FORMAT a15
COLUMN EVENT 		FORMAT a30
COLUMN OBJECT_OWNER	FORMAT a16    		HEAD 'OWNER'
COLUMN FQ_NAME 					noprint
COLUMN STALE_STATS	FORMAT a12		HEAD 'Stale Stats'
COLUMN STATTYPE_LOCKED	FORMAT a12		HEAD 'Stat Locked'
COLUMN EXECUTIONS	FORMAT 999,999,999
COLUMN DISK_READS	FORMAT 999,999,999	HEAD 'Disk Reads'
COLUMN BUFFER_GETS 	FORMAT 999,999,999	HEAD 'Buffer Gets'
COLUMN ROWS_PROCESSED	FORMAT 999,999,999	HEAD 'Rows Processed'

select a.INST_ID,a.sid,a.SERIAL#,a.sql_id,c.PLAN_HASH_VALUE,b.EXECUTIONS,b.DISK_READS,b.BUFFER_GETS,b.ROWS_PROCESSED,a.LAST_CALL_ET/3600 as Run_time_so_far,event
from gv$session a,gv$sqlarea b, gv$sqlstats c
where a.sql_id=b.sql_id 
and b.sql_id=c.sql_id
and status ='ACTIVE'
and a.sql_id=nvl('&sql_id','%');

