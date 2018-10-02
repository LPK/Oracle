select distinct
   dd.referenced_owner, 
   dd.referenced_name, 
   dd.referenced_type
   ,ds.table_name,ds.last_analyzed,ds.stale_stats
from 
   dba_dependencies dd
   
   inner join dba_tab_statistics  ds on dd.referenced_name =  ds.table_name
where name= 'INSERT_FRFOR_SIM' and dd.referenced_type ='TABLE' and dd.referenced_owner ='CMSADMIN';

select * from dba_tab_statistics where table_name ='V_FIRST_RECHARGETEMP_MID_FR';

/*and 
   owner = 'SYSTEM'
order by 
   referenced_owner, referenced_name, referenced_type;*/
   
   --check last analyzed 
   select owner,table_name,last_analyzed From dba_Tables;
   --check stale status
   select table_name, stale_stats, last_analyzed 
    from dba_tab_statistics 
    where stale_stats='YES';
    --gather stat
    exec DBMS_STATS.GATHER_TABLE_STATS (ownname => 'CMSADMIN' , tabname => 'V_FIRST_RECHARGETEMP_MID_FR',cascade => true, estimate_percent => 10,method_opt=>'for all indexed columns size 1', granularity => 'ALL', degree => 5);
    
	
	71uns5vu9a500