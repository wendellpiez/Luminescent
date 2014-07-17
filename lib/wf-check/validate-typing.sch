<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">

  <title>Validating range typing (step 8)</title>
  
  <!-- Assuming correct tagging syntax, validates types:
       annotations are clean; every start has an end, and
       every end has a start;
       GIs are well-formed, etc. -->

  <!--<include href="utility-functions.sch"/>-->
  
  <ns prefix="s" uri="http://lmnl-markup.org/ns/luminescent/tags"/>
  <ns prefix="util" uri="http://lmnl-markup.org/luminescent/schematron/util"/>
  
  
  
  <pattern>
    <rule context="s:*">
      <assert test="empty(@gi) or matches(@gi,'^\i\c*(=\i\c*)?\s*$')">
        Illegal name in <value-of select="util:tag(.)"/>
        at <value-of select="util:start-position(.)"/>,
        <value-of select="util:file-path(.)"/></assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="s:start">
      <assert test="exists(util:end-for-start(.))">
        No end tag matches start tag <value-of select="util:tag(.)"/>
        at <value-of select="util:start-position(.)"/>,
        <value-of select="util:file-path(.)"/>
      </assert>
    </rule>
    <rule context="s:end">
      <assert test="exists(@pID)">
        No start tag matches end tag <value-of select="util:tag(.)"/>
        at <value-of select="util:start-position(.)"/>,
        <value-of select="util:file-path(.)"/>
      </assert>
    </rule>
    
    <rule context="s:error">
      <!--<report test="empty($leader) and empty($follower)">-->
      <report test="true()">
        Error <value-of select="@type"/> reported
        <value-of select="string-join(
          ('for',util:tag(.),'at',util:start-position(.)),' ')"/>, 
        <value-of select="util:file-path(.)"/>
      </report>
    </rule>
  </pattern>

  <xsl:function name="util:URI-to-DOS" as="xs:string">
    <xsl:param name="URI" as="xs:anyURI"/>
    <xsl:value-of select="translate(replace($URI,'^file:/+',''),'/','\')"/>
  </xsl:function>
  
  
  <xsl:function name="util:tag" as="xs:string?">
    <!-- reports the name of an element, with 'a' or 'an' as appropriate -->
    <xsl:param name="tag" as="node()?"/>
    <xsl:variable name="delimiters" as="element()+">
      <!-- doubling curly braces since these are AVTs -->
      <tag type="doc" open="'" close="'">document</tag>  
      <tag type="annotation" open="'" close="'">annotation</tag>    
      <tag type="empty" open="[" close="]"/>  
      <tag type="start" open="[" close="}}"/>  
      <tag type="end" open="{{" close="]"/>  
      <tag type="atom" open="{{{{" close="}}}}"/>  
    </xsl:variable>
    <xsl:variable name="o" select="$delimiters[@type=local-name($tag)]/@open/string(.)"/> 
    <xsl:variable name="c" select="$delimiters[@type=local-name($tag)]/@close/string(.)"/> 
    <xsl:variable name="l" select="$delimiters[@type=local-name($tag)]/string(.)[normalize-space(.)]"/> 
    <xsl:value-of>
      <xsl:value-of select="string-join((concat($o,$tag/@gi,$c),$l),' ')"/>
      <xsl:value-of select="$tag/self::s:error/@type"/>
      <xsl:if test="empty($tag)">[???]</xsl:if>
    </xsl:value-of>
  </xsl:function>
  
  <xsl:key name="end-by-pID" match="s:end" use="@pID"/>
  
  <xsl:function name="util:end-for-start" as="element()?">
    <xsl:param name="start" as="element(s:start)"/>
    <xsl:sequence select="$start/@pID/key('end-by-pID',.)[.. is $start/..]"/>
  </xsl:function>
  
  <xsl:function name="util:start-position" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:variable name="where"
      select="($tag[exists(@sl|@so)],$tag/*[exists(@sl|@so)][1])[1]"/>
    <xsl:value-of select="string-join(($where/@sl, $where/@so),':')"/>
  </xsl:function>
  
  <xsl:function name="util:end-position" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:variable name="where" select="($tag[exists(@el|@eo)],$tag/*[exists(@el|@eo)][last()])[1]"/>
    <xsl:value-of select="string-join(($where/@el, $where/@eo),':')"/>
  </xsl:function>
  
  
  <xsl:function name="util:indefinite-name" as="xs:string?">
    <!-- reports the name of an element, with 'a' or 'an' as appropriate -->
    <xsl:param name="tag" as="node()"/>
    <xsl:value-of>
      <xsl:text>a</xsl:text>
      <xsl:if test="matches($tag/local-name(),'[aeiou]','i')">n</xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="local-name($tag)"/>
    </xsl:value-of>
  </xsl:function>
  
  <xsl:function name="util:file-path" as="xs:string?">
    <xsl:param name="tag" as="element()"/>
    <xsl:value-of select="$tag/root(.)/s:root/@base-uri/util:URI-to-DOS(.)"/>
  </xsl:function>

</schema>
