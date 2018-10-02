set lines 200
select ' exec dbms_stats.gather_table_stats(OWNNAME =>'''||object_owner||''' , TABNAME => '''||OBJECT_NAME||''' , METHOD_OPT => ''FOR ALL INDEXED COLUMNS SIZE AUTO'', CASCADE => TRUE, DEGREE => 20 , granularity => ''ALL''); 'Gather_STAT 
from gv$sql_plan a,dba_tab_statistics b where a.object_name=b.table_name and b.object_type='TABLE' and a.sql_id='&sql_id' and b.STALE_STATS='YES' and b.stattype_locked is null
/

