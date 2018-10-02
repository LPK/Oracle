
create table ex01_person_tb (
  id number,
  name varchar2(50)
);

insert into ex01_person_tb values (1, 'Roger Waters');
insert into ex01_person_tb values (2, 'David Gilmour');

/*
create table ex01_phone_tb (
  id number,
  person_id number,
  phone_number varchar2(50)
);

insert into ex01_phone_tb values (1, 1, '543 454433');

insert into ex01_phone_tb values (2, 1, '512 4776443');

insert into ex01_phone_tb values (3, 1, '521 6454423');

insert into ex01_phone_tb values (4, 2, '212 8332464');
*/


select a.id, a.name, cursor (select b.id, b.name
                            from ex01_person_tb b
                             ) as phone_numbers
 from ex01_person_tb a; 


--======================================================
CREATE function sql2xml(i_sql_string in varchar2) 
return xmltype is
    l_context_handle dbms_xmlgen.ctxhandle;
    l_xml            xmltype;
    l_rows           number;
begin
    -- returns a new context handle to be used in the following functions
    l_context_handle := dbms_xmlgen.newcontext(i_sql_string);    

    -- if null, give a empty tag (e.g. )
    dbms_xmlgen.setnullhandling(l_context_handle, dbms_xmlgen.empty_tag); 

    -- get the XML
    l_xml  := dbms_xmlgen.getxmltype(l_context_handle, dbms_xmlgen.none); 

    -- get back the number of rows
    l_rows := dbms_xmlgen.getnumrowsprocessed(l_context_handle);    

    -- close the handle
    dbms_xmlgen.closecontext(l_context_handle);     

    if l_rows > 0 then
      return(l_xml);
    else
      return(null);
    end if;

end;

--===================================================
declare
  l_sql_string varchar2(2000);
  l_xml        xmltype;
begin
  l_sql_string := 'select a.id, a.name ' ||
                  '     from ex01_person_tb a '; 

  -- Create the XML aus SQL
  l_xml := sql2xml(l_sql_string);
  -- Display the XML
  dbms_output.put_line(l_xml.getclobval());
end;


--=============================================

CREATE function get_xml_to_json_stylesheet 
return varchar2 is
    l_xslt_string varchar2(32000);

  begin

    l_xslt_string := '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
  <xsl:strip-space elements="*"/>
  <!--contant-->
  <xsl:variable name="d">0123456789</xsl:variable>

  <!-- ignore document text -->
  <xsl:template match="text()[preceding-sibling::node() or following-sibling::node()]"/>

  <!-- string -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- Main template for escaping strings; used by above template and for object-properties
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
  <xsl:template name="escape-string">
    <xsl:param name="s"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>
 
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,''\'')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''\''),''\\'')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,''\'')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'';'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'';''),''&quot;'')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,'';'')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,'';'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'';''),''\t'',substring-after($s,'';''))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,'';'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'';''),''\n'',substring-after($s,'';''))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,'';'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'';''),''\r'',substring-after($s,'';''))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- number (no support for javascript mantise) -->
  <xsl:template match="text()[not(string(number())=''NaN'')]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- boolean, case-insensitive -->
  <xsl:template match="text()[translate(.,''TRUE'',''true'')=''true'']">true</xsl:template>
  <xsl:template match="text()[translate(.,''FALSE'',''false'')=''false'']">false</xsl:template>

  <!-- item:null -->
  <xsl:template match="*[count(child::node())=0]">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="local-name()"/>
    </xsl:call-template>
    <xsl:text>:null</xsl:text>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">}</xsl:if> <!-- MBR 30.01.2010: added this line as it appeared to be missing from stylesheet -->
  </xsl:template>

  <!-- object -->
  <xsl:template match="*" name="base">
    <xsl:if test="not(preceding-sibling::*)">{</xsl:if>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="name()"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <xsl:apply-templates select="child::node()"/>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">}</xsl:if>
  </xsl:template>

  <!-- array -->
  <xsl:template match="*[count(../*[name(../*)=name(.)])=count(../*) and count(../*)&gt;1]">
    <xsl:if test="not(preceding-sibling::*)">[</xsl:if>
    <xsl:choose>
      <xsl:when test="not(child::node())">
        <xsl:text>null</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="child::node()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">]</xsl:if>
  </xsl:template>

  <!-- convert root element to an anonymous container -->
  <xsl:template match="/">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

</xsl:stylesheet>';

    return(l_xslt_string);

end;



--==============================================================
CREATE function xml2json(i_xml in xmltype) return xmltype is

    l_json xmltype;

begin

    l_json := i_xml.transform(xmltype(get_xml_to_json_stylesheet));
  
    return(l_json);

end;


--=====================Need a good parser================
declare
  l_sql_string varchar2(2000);
  l_xml        xmltype;
  l_json       xmltype;
begin
  l_sql_string := 'select a.id, a.name from ex01_person_tb a '; 

  -- Create the XML aus SQL
  l_xml := sql2xml(l_sql_string);

  -- Display the XML
  dbms_output.put_line(l_xml.getclobval());

  -- convert the JSON
  l_json := xml2json(l_xml);

  -- Display the JSON

  --dbms_output.put_line(l_json.getclobval());

end;

