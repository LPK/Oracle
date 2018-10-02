SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;


ACCEPT sql_id   CHAR PROMPT 'Enter SQL_ID info    : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report	: SQL ID and TEXT information				|
PROMPT | Instance	: &current_instance					| 
PROMPT | SQL_ID	: &sql_id						|
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET PAGESIZE    0
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
SET LONG 999999999
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
PROMPT Information from Cursor Cache.
PROMPT ++++++++++++++++++++++++++++++++
select SQL_ID,SQL_FULLTEXT from v$sqlarea where SQL_ID='&sql_id';

PROMPT Information from AWR.
PROMPT ++++++++++++++++++++++++++++++++
select SQL_ID,SQL_TEXT from dba_hist_sqltext where SQL_ID='&sql_id';

set pages 200

