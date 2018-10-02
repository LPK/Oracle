i-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_longops.sql                                                |
-- | CLASS    : session dtails                                                  |
-- | PURPOSE  : Query  long running session information.  	                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Long Running Operation                                      |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE  200 
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

 col OPNAME for a10
 col SID form 9999
 col SERIAL form 9999999
 col PROGRAM for a10
 col USERNAME for a10
 col SQL_TEXT for a40
 col START_TIME for a16
 col "MESSAGE" for a45
 col LAST_UPDATE_TIME for a16
 col TARGET for a25
 col MESSAGE for a25

 alter session set nls_date_format='DD-MON-RR HH24:MI';
 SELECT sid, serial#, sql_id, username, start_time,round(time_remaining/60,2) "REMAIN MINS", round(elapsed_seconds/60,2) "ELAPSED MINS", round((time_remaining+elapsed_seconds)/60,2) "TOTAL MINS", ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE", message
 FROM gv$session_longops 
 WHERE TOTALWORK != 0 AND sofar<>totalwork AND time_remaining > 0 
 /

