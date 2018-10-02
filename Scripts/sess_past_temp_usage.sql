
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';

ACCEPT sql_id   CHAR PROMPT 'Enter SQL_ID that needs to checked for	: ' 
ACCEPT sid   	CHAR PROMPT 'Enter SID that needs to checked for	: '
ACCEPT serial  CHAR PROMPT 'Enter SERIAL# that needs to checked   	: '
ACCEPT time CHAR PROMPT 'Enter Sample time which you desire (DD-MON-RR)	: '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   	: Temp Usage for SQL/SID  in the past                   |
PROMPT | Instance 	: &current_instance                                     |
PROMPT | SQL_ID	: &sql_id						|
PROMPT | SID		: &sid							|
PROMPT | serial#	: &serial							|
PROMPT | Sample Time	: &timei						|
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

set lines 200 pages 200
col sample_time for a40
col "Temp Space USed in GB" for 999999999999999999
select  sample_time,SESSION_ID, SESSION_SERIAL# , SQL_ID,round(TEMP_SPACE_ALLOCATED/1024/1024,2) "Temp Space USed in MB" from dba_hist_active_sess_history
where sql_id like nvl('&sql_id','%')
and SESSION_ID  like nvl('&sid','%')
and SESSION_SERIAL# like nvl('&serial','%')
and sample_time like nvl('&time%','%')
order by sample_time;

