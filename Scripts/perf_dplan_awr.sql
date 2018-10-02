-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_dplan_cursor	                                        |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To find  the execution plan for sql_id in AWR			|
-- |                                                 		     		|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

ACCEPT sql_id CHAR 		PROMPT 'Enter value for SQL_ID : '
ACCEPT plan_hash_value CHAR 	PROMPT 'Enter Plan Hast Value  : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Execution Plan for SQL_ID in AWR				|
PROMPT | Instance : &current_instance						|
PROMPT | SQL_ID   : &sql_id						|
PROMPT | PHV	  : &plan_hash_value							|
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



SELECT * FROM table(dbms_xplan.display_awr(nvl('&sql_id','a96b61z6vp3un'),nvl('&plan_hash_value',null),null,'typical +peeked_binds'));

