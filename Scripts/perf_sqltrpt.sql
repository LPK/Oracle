-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_sqltrpt		                                        |
-- | CLASS    : Performance Tuning                                   		|
-- | PURPOSE  : To run sqltrpt from $ORACLE_HOME/rdbms/admin   			|
-- |                                                 		     		|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+



SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;


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


col SQL_TEXT_FRAGMENT for a90
@?/rdbms/admin/sqltrpt
