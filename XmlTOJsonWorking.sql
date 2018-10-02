CREATE OR REPLACE FUNCTION get_json_fnc(ip_rfc VARCHAR2) RETURN CLOB AS
      
        lhtmloutput   xmltype;
        lxsl          LONG;
        lxmldata      xmltype;
        lcontext      dbms_xmlgen.ctxhandle;
        l_ret_clob    CLOB;
        desc_cur      NUMBER;
        l_descr_tab   dbms_sql.desc_tab2;
        l_num_cols    NUMBER;
        l_header_clob CLOB;
        l_row_data    VARCHAR2(4000);
        l_ip_rfc      SYS_REFCURSOR;
        l_exec_comm   VARCHAR2(4000);
BEGIN
        l_exec_comm := 'SELECT ' || ip_rfc || ' from dual';
        dbms_output.put_line('ABC1');                
        EXECUTE IMMEDIATE l_exec_comm INTO l_ip_rfc;

        l_header_clob := '{"metadata":[';
        desc_cur      := dbms_sql.to_cursor_number(l_ip_rfc);

        dbms_sql.describe_columns2(desc_cur ,l_num_cols ,l_descr_tab);
        
        dbms_output.put_line('ABC2');                          
        dbms_output.put_line(l_num_cols);
        
        FOR i IN 1 .. l_num_cols
        LOOP
                CASE
                        WHEN l_descr_tab(i).col_type IN (2 ,8) THEN
                                l_row_data := '{"name":"' || l_descr_tab(i).col_name || '","type":"number"},';
                        WHEN l_descr_tab(i).col_type = 12 THEN
                                l_row_data := '{"name":"' || l_descr_tab(i).col_name || '","type":"date"},';
                        ELSE
                                l_row_data := '{"name":"' || l_descr_tab(i).col_name || '","type":"text"},';
                END CASE;
                dbms_lob.writeappend(l_header_clob ,length(l_row_data),l_row_data);
        END LOOP;
        
        dbms_output.put_line('ABC3');     
        
        l_header_clob := rtrim(l_header_clob ,',') || '],"data":';

        EXECUTE IMMEDIATE l_exec_comm INTO l_ip_rfc;
        
        lcontext := dbms_xmlgen.newcontext(l_ip_rfc);
        dbms_output.put_line('ABC4');    
        
        dbms_xmlgen.setnullhandling(lcontext ,1);
        
        lxmldata := dbms_xmlgen.getxmltype(lcontext  ,dbms_xmlgen.none);
        -- this is a XSL for JSON
        lxsl := '<?xml version="1.0" encoding="ISO-8859-1"?>
        <xsl:stylesheet version="1.0"
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output method="html"/>
        <xsl:template match="/">[<xsl:for-each select="/ROWSET/*">
          {<xsl:for-each select="./*">
            "<xsl:value-of select="name()"/>":"<xsl:value-of select="text()"/>"<xsl:choose>
              <xsl:when test="position()!= last()">,</xsl:when>
            </xsl:choose>
           </xsl:for-each>
          }<xsl:choose>
              <xsl:when test="position() != last()">,</xsl:when>
            </xsl:choose>
           </xsl:for-each>
        ]}]}</xsl:template></xsl:stylesheet>';
        
         dbms_output.put_line('ABC5');   
          
         
        lhtmloutput := lxmldata.transform(xmltype(lxsl));
        l_ret_clob  := lhtmloutput.getclobval();
        l_ret_clob  := REPLACE(l_ret_clob,'_x0020_',' ');
        
        dbms_output.put_line('ERROR');
        
        --dbms_output.put_line(l_ret_clob); 
        --dbms_output.put_line(l_header_clob);
          
        --dbms_lob.append(l_header_clob,length(l_ret_clob),l_ret_clob);
      
        dbms_output.put_line('ABC6');
        
        RETURN l_header_clob;
        
EXCEPTION
        WHEN OTHERS THEN
                
                dbms_output.put_line('ABC999');
                l_header_clob := SQLERRM;
                dbms_output.put_line(dbms_utility.format_error_backtrace);
                RETURN l_header_clob;
END get_json_fnc;
--=========================================
create or replace function get_ten_records
return SYS_REFCURSOR
as
rec_cursor SYS_REFCURSOR;
begin

open rec_cursor for select * from item where rownum < 10000;
return rec_cursor;
end;
--==================================================
SELECT get_json_fnc('get_ten_records()') AS contact_json 
FROM dual;

 