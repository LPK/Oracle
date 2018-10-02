
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';

ACCEPT username     CHAR PROMPT 'Enter username to find past blocking  	: ' 
ACCEPT start_time   CHAR PROMPT 'Start Time (DD-MON-YYYY HH24:MI:SS) 	: '
ACCEPT end_time     CHAR PROMPT 'End Time (DD-MON-YYYY HH24:MI:SS)   	: '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   	: Blocking Sessions in the past                         |
PROMPT | Instance 	: &current_instance                                     |
PROMPT | Userame	: &username						|
PROMPT | Start Time	: &start_time					|
PROMPT | End Time	: &end_time					|
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

column event for a30


SELECT  distinct a.sql_id,a.inst_id,a.blocking_session,a.blocking_session_serial#,a.user_id,a.event 
FROM  GV$ACTIVE_SESSION_HISTORY a  ,gv$sql s 
where a.sql_id=s.sql_id and blocking_session is not null
and a.sample_time between '&start_time' and '&end_time' 
and a.user_id in (select user_id from dba_users where username like '%&username%'); 


