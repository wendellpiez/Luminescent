<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2">
  
  <title>Validating tags (step 4)</title>
<!-- Validates structure of tags after tag-wrapping tokens -->

  <ns prefix="t" uri="http://lmnl-markup.org/ns/luminescent/tokens"/>
  <ns prefix="s" uri="http://lmnl-markup.org/ns/luminescent/tags"/>
  <ns prefix="local" uri="http://lmnl-markup.org/ns/local"/>
  
  <pattern>
    <rule context="s:tag">
      <let name="opendelimiter" value="('{','[')"/>
      <let name="closedelimiter" value="(']','}')"/>
      <assert test="*[1]/self::t:d = $opendelimiter">
        tags all start with <value-of select="local:or-seq($opendelimiter)"/>
        ... check <value-of select="local:start-position(.)"/>,
        <value-of select="local:file-path(.)"/>
      </assert>
      <assert test="*[last()]/self::t:d = $closedelimiter">
        tags must end with  <value-of select="local:or-seq($closedelimiter)"/> ... check after
        <value-of select="local:end-position(.)"/>,
        <value-of select="local:file-path(.)"/>
      </assert>
      <!--<report test="*[last()]/local:end-position(.)">
        look at 
        <value-of select="local:end-position(.)"/>)
      </report>-->
    </rule>
  </pattern>


  <xsl:function name="local:start-position" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:variable name="where" select="($tag[exists(@l|@o)],$tag/*[exists(@l|@o)][1])[1]"/>
    <xsl:value-of
      select="string-join(($where/@l, $where/@o),':')"/>
  </xsl:function>
  
  <xsl:function name="local:end-position" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:variable name="where" select="($tag[exists(@l|@o)],$tag/*[exists(@l|@o)][last()])[1]"/>
    <xsl:value-of
      select="string-join(($where/@l, $where/@o),':')"/>
  </xsl:function>
  
  <xsl:function name="local:file-path" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:value-of select="$tag/root(.)/s:root/@base-uri/local:URI-to-DOS(.)"/>
  </xsl:function>
  
  
  <xsl:function name="local:or-seq" as="xs:string?">
    <xsl:param name="seq" as="xs:string*"/>
    <xsl:value-of>
      <xsl:for-each select="$seq">
        <xsl:value-of
          select="."/>
        <xsl:if test="not(position() eq last())">
          <xsl:choose>
            <xsl:when test="position() eq (last()) -1">,</xsl:when>
            <xsl:otherwise> or</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:value-of>
    
  </xsl:function>

  <xsl:function name="local:URI-to-DOS" as="xs:string">
    <xsl:param name="URI" as="xs:anyURI"/>
    <xsl:value-of select="translate(replace($URI,'^file:/+',''),'/','\')"/>
  </xsl:function> 
  
  
  
</schema>
