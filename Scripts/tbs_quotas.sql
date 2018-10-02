-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_quotas.sql		                                        |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on TBS quotas for user. This script was designed to     |
-- |            work with Oracle8i or higher. It will include true TEMPORARY    |
-- |            tablespaces. (i.e. use of "tempfiles")                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

ACCEPT username   CHAR PROMPT 'Enter username whom you wish to find tbs quotas for : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace Quota information for a user                     |
PROMPT | Instance : &current_instance                                           |
PROMPT | Username : &username							|
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

BREAK ON report

select * from dba_ts_quotas
where upper(username)=upper('&username');

