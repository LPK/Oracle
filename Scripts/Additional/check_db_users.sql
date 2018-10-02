set lines 400
column USERNAME format a30
column USER_ID format a40
 
SET PAGESIZE 100

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report	: DBA USERS				| 
PROMPT +------------------------------------------------------------------------+

column ACCOUNT_STATUS format a20
column LOCK_DATE format a10
column EXPIRY_DATE format a10
column CREATED  format a10
column LAST_LOGIN  format a50

select USERNAME, USER_ID,   ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE , CREATED , LAST_LOGIN  from dba_users;
 begin
DBMS_OUTPUT.PUT_LINE('++++++++++++++++++++++++');
dbms_output.put_line('All - Users');
dbms_output.put_line('++++++++++++++++++++++++');
end;

select USERNAME, USER_ID,  CREATED  from all_users;
