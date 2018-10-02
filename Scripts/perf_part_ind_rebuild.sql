select 'alter index '||INDEX_OWNER||'.'||index_name||' rebuild partition '||partition_name||';' from  dba_ind_partitions where index_name = '&Index_Name';
