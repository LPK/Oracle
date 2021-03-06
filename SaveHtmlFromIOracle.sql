CREATE OR REPLACE FUNCTION fncRefCursor2HTML(rf SYS_REFCURSOR)
RETURN CLOB
IS
lRetVal      CLOB;
lHTMLOutput  XMLType;

lXSL         CLOB;
lXMLData     XMLType;

lContext     DBMS_XMLGEN.CTXHANDLE;
BEGIN
-- get a handle on the ref cursor --
lContext := DBMS_XMLGEN.NEWCONTEXT(rf);
-- setNullHandling to 1 (or 2) to allow null columns to be displayed --
DBMS_XMLGEN.setNullHandling(lContext,1);
-- create XML from ref cursor --
lXMLData := DBMS_XMLGEN.GETXMLTYPE(lContext,DBMS_XMLGEN.NONE);

-- this is a generic XSL for Oracle's default XML row and rowset tags --
-- " " is a non-breaking space --
lXSL := lXSL || q'[<?xml version="1.0" encoding="ISO-8859-1"?>]';
lXSL := lXSL || q'[<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">]';
lXSL := lXSL || q'[ <xsl:output method="html"/>]';
lXSL := lXSL || q'[ <xsl:template match="/">]';
lXSL := lXSL || q'[ <html>]';
lXSL := lXSL || q'[  <body>]';
lXSL := lXSL || q'[   <table border="1">]';
lXSL := lXSL || q'[     <tr bgcolor="cyan">]';
lXSL := lXSL || q'[      <xsl:for-each select="/ROWSET/ROW[1]/*">]';
lXSL := lXSL || q'[       <th><xsl:value-of select="name()"/></th>]';
lXSL := lXSL || q'[      </xsl:for-each>]';
lXSL := lXSL || q'[     </tr>]';
lXSL := lXSL || q'[     <xsl:for-each select="/ROWSET/*">]';
lXSL := lXSL || q'[      <tr>]';
lXSL := lXSL || q'[       <xsl:for-each select="./*">]';
lXSL := lXSL || q'[        <td><xsl:value-of select="text()"/> </td>]';
lXSL := lXSL || q'[       </xsl:for-each>]';
lXSL := lXSL || q'[      </tr>]';
lXSL := lXSL || q'[     </xsl:for-each>]';
lXSL := lXSL || q'[   </table>]';
lXSL := lXSL || q'[  </body>]';
lXSL := lXSL || q'[ </html>]';
lXSL := lXSL || q'[ </xsl:template>]';
lXSL := lXSL || q'[</xsl:stylesheet>]';

-- XSL transformation to convert XML to HTML --
lHTMLOutput := lXMLData.transform(XMLType(lXSL));
-- convert XMLType to Clob --
lRetVal := lHTMLOutput.getClobVal();

RETURN lRetVal;
END fncRefCursor2HTML;
/


--==================================================

 variable x clob
  declare
          l_cursor sys_refcursor;
   begin
          open l_cursor for select *
          from Agent where rownum = 1;
           :x := fncRefCursor2HTML( l_cursor );
           close l_cursor;
   end;
  /
  --==================================================
   print x