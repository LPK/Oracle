-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_locked.sql                                                 |
-- | CLASS    : Performance Tuning                                    		|
-- | PURPOSE  : To find locked objects in the database	     			|
-- |                                                 		     		|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Locked Objects                                              |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE   200 
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
COLUMN username          FORMAT a24        HEAD 'User Name'
COLUMN INST_ID		    FORMAT 999999   
COLUMN MACHINE		    FORMAT a20
COLUMN INST_ID		    FORMAT 999999 
COLUMN LOGON_TIME	    FORMAT a20		HEAD 'Logon Time'
COLUMN OSUSER 		    FORMAT a18		HEAD 'OS User'
COLUMN TERMINAL		    FORMAT a15
COLUMN SESS_ID		    FORMAT a13		HEAD 'SESSION ID'
COLUMN OBJECT		    FORMAT a46		HEAD 'OBJECT NAME'
COLUMN TERMINAL		    FORMAT a15
COLUMN mode_held FORMAT a12
select    oracle_username || ' (' || s.osuser || ')' username
,               s.sid || ',' || s.serial#||',@'||s.inst_id  sess_id
,               owner || '.' ||   object_name object
,               object_type
,               decode(               l.block
                ,               0, 'Not Blocking'
                ,               1, 'Blocking'
                ,               2, 'Global') status
,               decode(v.locked_mode
                ,               0, 'None'
                ,               1, 'Null'
                ,               2, 'Row-S (SS)'
                ,               3, 'Row-X (SX)'
                ,               4, 'Share'
                ,               5, 'S/Row-X (SSX)'
                ,               6, 'Exclusive', TO_CHAR(lmode)) mode_held
from      gv$locked_object v
,               dba_objects d
,               gv$lock l
,               gv$session s
where   v.object_id = d.object_id
and        v.object_id = l.id1
and        v.session_id = s.sid
order by oracle_username
,               session_id
/

