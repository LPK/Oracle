TABASE : Oracle                                                          |
-- | FILE     : perf_phv_active.sql                                             |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To find execution statisics for sql that ran in past		|
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
PROMPT | Report   : Execution Statistics for SQL_ID in the past                 |
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
COLUMN INST_ID		FORMAT 9999		HEAD 'Node'
COLUMN LOGON_TIME	FORMAT a20		HEAD 'Logon Time'
COLUMN OSUSER 		FORMAT a18		HEAD 'OS User'
COLUMN TERMINAL		FORMAT a15
COLUMN SESS_ID		FORMAT a10		HEAD 'SESSION ID'
COLUMN OBJECT		FORMAT a20		HEAD 'OBJECT NAME'
COLUMN TERMINAL		FORMAT a15
COLUMN OBJECT_OWNER	FORMAT a16    		HEAD 'OWNER'
COLUMN FQ_NAME 					noprint
COLUMN STALE_STATS	FORMAT a12		HEAD 'Stale Stats'
COLUMN STATTYPE_LOCKED	FORMAT a12		HEAD 'Stat Locked'
COLUMN EXECUTIONS	FORMAT 999,999,999
COLUMN DISK_READS	FORMAT 999,999,999	HEAD 'Disk Reads'
COLUMN BUFFER_GETS 	FORMAT 999,999,999	HEAD 'Buffer Gets'
COLUMN ROWS_PROCESSED	FORMAT 999,999,999	HEAD 'Rows Processed'
COLUMN EXECS		FORMAT 999,999,999	
COLUMN AVG_ETIME	FORMAT 999,999,999	HEAD 'Avg Exec Time'
COLUMN AVG_LIO		FORMAT 999,999,999	HEAD 'Avg Buffer Gets'
COLUMN BEGIN_INTERVAL_TIME FORMAT a25		HEAD 'Begin Time'
COLUMN SQL_PROFILE	FORMAT a35		HEAD 'SQL Profile'

alter session set nls_date_format='DD-MM-RR HH24:MI';
break on plan_hash_value on startup_time skip 1

select ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio, SQL_PROFILE
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 2 
/

