
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Unusable Index and Compilation 				|
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+


SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET LONG        9000
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

PROMPT 
PROMPT UNUSABLE INDEX INFORMATION  
PROMPT +------------------------------+

select OWNER, TABLE_NAME, INDEX_NAME, status
from dba_indexes where status = 'UNUSABLE';
PROMPT 
col COL2 HEADING 'SYNTAX TO COMPILE INDEX'
select 'ALTER INDEX '||owner||'.'||index_name|| ' REBUILD PARALLEL 8;' COL2
from dba_indexes where status = 'UNUSABLE';


col col3 heading 'POST INDEX COMPILATION SCRIPT - PARALLEL to 1'
select 'ALTER INDEX '||owner||'.'||index_name|| ' PARALLEL 1;' COL3
from dba_indexes where status = 'UNUSABLE';


