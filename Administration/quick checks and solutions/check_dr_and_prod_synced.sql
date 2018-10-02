

Check oracle os mount point size DR 
then check archive mount point space  DR

if oracle is fill - clear the oracle first 
					then clear the archive log throug rman if the policy id  delete after appied 
					
	
delete archivelog all
	
delete archivelog all completed before 'sysdate - 1'

delete archivelog all completed before 'sysdate - 6/24'

--in production
sqlplus / as sysdba

archive log list

--in DR
sqlplus / as sysdba

desc v$archived_log

column namd format a35

select max(SEQUENCE#) from v$archived_log where APPLIED='YES';

---check for the MRP 

select PROCESS,GROUP#,THREAD# from v$managed_standby;

#############################################################################################################

--DR DOWN AND START 
-------------------------------------------------http://www.aodba.com/steps-stop-start-oracle-standby-database/
lsnrctl stop 

alter database recover managed standby database cancel;

shutdown immediate;

else 

shutdown Abort;

------------------Can be happen this --- https://askdba.org/weblog/2008/05/shutdown-immediate-hang-2/



startup nomount;	

alter database mount standby database;

select name,open_mode from v$database;

alter database recover managed standby database disconnect from session;

alter database open read only;

select name,open_mode from v$database;

lsnrctl start 

--in production  do a log switch  
-------------------------------------------------

ALTER SYSTEM SWITCH LOGFILE;

#############################################################################################################









Oracle Errors 
=============================================================================================
Errors in file /oracle/diag/rdbms/sandi_stby/sandi/trace/sandi_rfs_8032.trc:
ORA-00313: open failed for members of log group 4 of thread 1
ORA-00312: online log 4 thread 1: '/redo4a/sandi/stby_log_4a.dbf'
ORA-27037: unable to obtain file status
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
RFS[1]: Selected log 6 for thread 1 sequence 156974 dbid 573491198 branch 914278605

-----------

Errors in file /oracle/diag/rdbms/sandi_stby/sandi/trace/sandi_pmon_5100.trc:
ORA-03170: deadlocked on readable physical standby (undo segment 65535)

