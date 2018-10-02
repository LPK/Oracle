set lines 200
col FILE_NAME for a50
select FILE_NAME,TABLESPACE_NAME, bytes/(1024*1024*1024) GB from dba_temp_files;
