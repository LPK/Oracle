-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_undo_usage.sql                                        	|
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all undo  usage. This script was designed to     	|
-- |            work with Oracle8i or higher. It will include true TEMPORARY    |
-- |            tablespaces. (i.e. use of "tempfiles")                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Undo Usage                                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN username 	FORMAT a15
COLUMN undo_used_mb	FORMAT 999,999,999	HEADING 'Undo Used (MB)'
COLUMN inmb 		FORMAT 999,999,999	HEADING 'Size (MB)'
COMPUTE sum OF filesize  ON report
COMPUTE sum OF used      ON report
COMPUTE avg OF pct_used  ON report

col sql_text format a40
set lines 130
select  s.inst_id,s.sid,s.serial#, s.username, s.sql_id, t.USED_UREC Records, t.USED_UBLK Blocks, (t.USED_UBLK*8192/1024/1024) undo_used_mb 
from gv$transaction t, gv$session s,gv$sql sq 
where t.addr = s.taddr
and s.sql_id = sq.sql_id;

PROMPT 
select status,sum(bytes/1024/1024) inmb from dba_undo_extents
group by status, tablespace_name;


