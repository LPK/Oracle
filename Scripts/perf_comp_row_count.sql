
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

ACCEPT sql_id CHAR PROMPT 'Enter value for SQL_ID : '

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Row Count comarision between Actual and Optimizor		|
PROMPT | Instance : &current_instance						|
PROMPT | SQL_ID   : &sql_id						|
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE   200
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF


SET SERVEROUT ON
SET Line 165

DECLARE
TYPE cur_type IS REF CURSOR;
TYPE cur_type1 IS REF CURSOR;
CURSOR tabinfo_cur IS
       select distinct OBJECT_OWNER, OBJECT_NAME
         from DBA_HIST_SQL_PLAN where sql_id='&sql_id'
         AND object_type='TABLE'
         order by 1, 2;
     count_cur cur_type;
     count_cur1 cur_type1;
     cnt number;
     l_cur_string VARCHAR2(228);
     l_cur_string1 VARCHAR2(228);
     l_tabcount varchar2(30);
     l_dictount varchar2(30);
 BEGIN
 dbms_output.put_line(chr(10));
 dbms_output.put_line( rpad('NO',4)||rpad('<OWNER>.<TABLE NAME>' ,50,'-')||'> '|| rpad('ACTUAL ROWS',15,'-')||'> '||'DICT ROWS');
 cnt := 0;
    FOR client IN tabinfo_cur LOOP
         l_cur_string := 'select count(*) from '||client.OBJECT_OWNER||'.'||client.OBJECT_NAME;
         OPEN count_cur FOR l_cur_string;
         l_cur_string1 := 'select num_rows from dba_tables where owner'||q'[=']'||client.OBJECT_OWNER||q'[' and table_name=']'||client.OBJECT_NAME||q'[']';
         OPEN count_cur1 FOR l_cur_string1;
         cnt := cnt + 1;
        LOOP
             FETCH count_cur INTO l_tabcount;
             EXIT WHEN count_cur%NOTFOUND;
          LOOP
             FETCH count_cur1 INTO l_dictount;
             EXIT WHEN count_cur1%NOTFOUND;
             dbms_output.put_line( rpad(cnt,4)||rpad(client.OBJECT_OWNER||'.'||client.OBJECT_NAME ,50,'-')||'> '|| rpad(l_tabcount,15,'-')||'> '||l_dictount);
         END LOOP;
         CLOSE count_cur1;
         END LOOP;
         CLOSE count_cur;
     END LOOP;
 END;
/

