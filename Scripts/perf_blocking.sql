-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_blocking.sql                                               |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To find the blocking session     				|
-- |                                                 				|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Blocking Sessions                                           |
PROMPT | Instance : &current_instance                                           |
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

COLUMN wait_class        FORMAT a26        HEAD 'Wait Class'
COLUMN username          FORMAT a18        HEAD 'User Name'

select 
	inst_id
	, username
	, sid
	, serial#
	, blocking_session
	,wait_class,sql_id
	, seconds_in_wait
from 
	gv$session
where 
	blocking_session is not NULL
order 
	by blocking_session
/


