SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace and Filesystem Usage 			         |
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

COLUMN tablespace  FORMAT a22                 HEADING 'Tablespace Name'
COLUMN filename    FORMAT a60                 HEADING 'Filename'
COLUMN filesize    FORMAT 9,999,999,999       HEADING 'File Size (Mb)'
COLUMN used        FORMAT 9,999,999,999       HEADING 'Used (Mb)'
COLUMN pct_used    FORMAT 999                 HEADING 'Pct. Used'


set lines 165
set pages 2000
PROMPT
PROMPT TABLESPACE USAGE
PROMPT +++++++++++++++++++
select df.tablespace_name "TBSP", df.Ct "No of Datafiles", df.TotSize "Total (MB)", fr.FreSpac "Free (MB)",round((fr.FreSpac/df.TotSize)*100,2) "% Free",
round(df.TotSize-fr.FreSpac,0) "Used (MB)",round(((df.TotSize-fr.FreSpac)/df.TotSize)*100,2) "% Used"
from (Select tablespace_name,round(sum(bytes)/(1024*1024),0) TotSize,count(file_name) Ct
from dba_data_files group by tablespace_name) df,
(Select tablespace_name,round(sum(bytes)/(1024*1024),0) FreSpac
from dba_free_space group by tablespace_name) fr
where df.tablespace_name=fr.tablespace_name order by 7 desc
/ 
PROMPT
PROMPT FILESYSTEM USAGE
PROMPT ++++++++++++++++
PROMPT

!df -h | egrep 'Filesystem|u02|u03'

col PATH for a45
col DG_NAME for a15
col DG_STATE for a10
col FAILGROUP for a15
select name, TOTAL_MB, FREE_MB, HOT_USED_MB, COLD_USED_MB, ROUND((TOTAL_MB-FREE_MB)/TOTAL_MB*100,2) USED_PCT from v$asm_diskgroup where TOTAL_MB != 0;


