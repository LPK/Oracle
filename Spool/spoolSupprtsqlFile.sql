set heading on
set linesize 1500
set colsep '|'
set numformat 99999999999999999999
set pagesize 25000
set sqlformat csv
spool E:\spool\abc.csv
@E:\spool\spoolSupprtsqlFile.sql;
spool off