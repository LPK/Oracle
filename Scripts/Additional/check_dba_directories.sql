set lines 200
column Owner format a30
column DIRECTORY_NAME format a30
column DIRECTORY_PATH format a70

select Owner,DIRECTORY_NAME,DIRECTORY_PATH from dba_directories;