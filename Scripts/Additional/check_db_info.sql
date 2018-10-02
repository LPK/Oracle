-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_info.sql
-- Author       : Tim Hall
-- Description  : Displays general information about the database.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @db_info
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 10000
SET LINESIZE 10000
SET FEEDBACK OFF

COLUMN DBID FORMAT A40
COLUMN NAME FORMAT A20
COLUMN CREATED FORMAT A20
COLUMN LOG_MODE FORMAT A30
COLUMN OPEN_MODE FORMAT A20
COLUMN PROTECTION_MODE FORMAT A20
COLUMN DB_UNIQUE_NAME FORMAT A20

SELECT DBID,NAME,CREATED,LOG_MODE,OPEN_MODE,PROTECTION_MODE, DB_UNIQUE_NAME  
FROM   v$database;

COLUMN INSTANCE_NAME FORMAT A20
COLUMN HOST_NAME FORMAT A20
COLUMN PARALLEL FORMAT A20
COLUMN DATABASE_STATUS FORMAT A30
COLUMN INSTANCE_MODE FORMAT A20
 
SELECT INSTANCE_NAME,HOST_NAME,PARALLEL,DATABASE_STATUS,INSTANCE_MODE
FROM   v$instance;

SELECT BANNER,CON_ID
FROM   v$version;

SELECT a.name,       a.valueFROM   
v$sga a;

SELECT Substr(c.name,1,60) "Controlfile",
       NVL(c.status,'UNKNOWN') "Status"
FROM   v$controlfile c
ORDER BY 1;

SELECT Substr(d.name,1,60) "Datafile",
       NVL(d.status,'UNKNOWN') "Status",
       d.enabled "Enabled",
       LPad(To_Char(Round(d.bytes/1024000,2),'9999990.00'),10,' ') "Size (M)"
FROM   v$datafile d
ORDER BY 1;

SELECT l.group# "Group",
       Substr(l.member,1,60) "Logfile",
       NVL(l.status,'UNKNOWN') "Status"
FROM   v$logfile l
ORDER BY 1,2;

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON