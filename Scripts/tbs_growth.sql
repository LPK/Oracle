-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_quotas.sql		                                        |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on TBS growth. This script was designed to     |
-- |            work with Oracle8i or higher. It will include true TEMPORARY    |
-- |            tablespaces. (i.e. use of "tempfiles")                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

ACCEPT tbs_name   CHAR PROMPT 'Enter tablespace name : '

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace growth  information 		                |
PROMPT | Instance : &current_instance                                           |
PROMPT | Username : &tbs_name							|
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

set linesize 120
column name format a15
column variance format a20
alter session set nls_date_format='yyyy-mm-dd';
with t as (
select ss.run_time,ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb,
round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from
dba_hist_tbspc_space_usage su,
(select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot 
group by trunc(BEGIN_INTERVAL_TIME) ) ss,
v$tablespace ts,
dba_tablespaces dt
where su.snap_id = ss.snap_id
and   su.tablespace_id = ts.ts#
and   ts.name          =upper('&tbs_name')
and   ts.name          = dt.tablespace_name )
select e.run_time,e.name,e.alloc_size_gb,e.used_size_gb curr_used_size_gb,b.used_size_gb prev_used_size_gb,
case when e.used_size_gb > b.used_size_gb then to_char(e.used_size_gb - b.used_size_gb)
     when e.used_size_gb = b.used_size_gb then '***NO DATA GROWTH'
     when e.used_size_gb < b.used_size_gb then '******DATA PURGED' end variance
from t e, t b
where e.run_time = b.run_time + 1
order by 1;

