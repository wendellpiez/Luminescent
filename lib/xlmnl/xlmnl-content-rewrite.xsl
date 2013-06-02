<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">

  <!-- rewrites x:content/x:span elements to correspond
       with sibling x:range elements
       (if they happen to have been altered) -->


  <xsl:strip-space elements="*"/>

  <xsl:preserve-space elements="x:span"/>

  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <xsl:apply-templates mode="rewrite"/>    
  </xsl:template>

  <xsl:template mode="rewrite" match="@*"/>
  
  <xsl:template mode="rewrite" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <!--<xsl:template match="x:document | x:annotation">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="generate-content">
        <xsl:with-param name="layer" select="."/>
        <xsl:with-param name="frontier" select="x:frontier/string()"/>
      </xsl:call-template>
      <xsl:apply-templates mode="rewrite" select="x:range"/>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template match="x:document | x:annotation" mode="rewrite">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:content" mode="rewrite"
    name="generate-content">
    <xsl:param name="layer" select=".."/>
    <xsl:param name="frontier" select="string()"/>
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <!--<xsl:value-of select="f:boundaries($layer)"/>-->
      <xsl:for-each select="remove(f:boundaries($layer),1)">
        <xsl:variable name="p" select="position()"/>
        <xsl:variable name="s" select="f:boundaries($layer)[$p]"/>
        <xsl:variable name="e" select="."/>
        <x:span start="{$s}" end="{$e}">
          <xsl:attribute name="layer">
            <xsl:apply-templates select="$layer/@ID" mode="rewrite"/>
          </xsl:attribute>
          <xsl:if test="exists(f:covering($layer,$s,$e))">
            <xsl:attribute name="ranges" separator=" ">
              <xsl:apply-templates mode="id" select="f:covering($layer,$s,$e)/@ID"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="substring($frontier,$s + 1,($e - $s))"/>
        </x:span>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="rewrite" match="@ID">
    <xsl:attribute name="ID">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template mode="id" as="xs:string"
    match="x:document/@ID | x:annotation/@ID">
    <xsl:value-of select="string-join(('L',generate-id()),'.')"/>
  </xsl:template>

  <xsl:template mode="id" as="xs:string"
    match="x:range/@ID">
    <xsl:value-of select="string-join((../@name,generate-id()),'.')"/>
  </xsl:template>

  <xsl:template mode="rewrite"
    match="@start | @end | @name">
    <xsl:copy-of select="."/>
  </xsl:template>


  <!--<xsl:function name="f:frontier" as="xs:string">
    <xsl:param name="layer" as="element()"/>
    <xsl:value-of select="$layer/x:content"/>
  </xsl:function>-->

  <xsl:function name="f:boundaries" as="xs:integer*">
    <!-- returns all the offsets of range boundaries as a sequence
         of integers, except the first (0) -->
    <xsl:param name="layer" as="element()"/>
    <xsl:if test="not($layer/x:range/@start = 0)">
      <xsl:sequence select="0"/>
    </xsl:if>
    <xsl:for-each-group select="$layer/x:range/(@start | @end)" group-by=".">
      <xsl:sort order="ascending" data-type="number" select="current-grouping-key()"/>
      <xsl:sequence select="xs:integer(.)"/>
    </xsl:for-each-group>
    <xsl:if test="not($layer/x:range/@end = string-length($layer))">
      <xsl:sequence select="string-length($layer)"/>
    </xsl:if>
  </xsl:function>
  
  <!--<xsl:key name="ranges-starting-before" match="x:range" use="f:boundaries(..)[. &gt;= current()/@start]"/>
  
  <xsl:key name="ranges-ending-after" match="x:range" use="f:boundaries(..)[. &lt;= current()/@end]"/>-->
  
  <xsl:function name="f:covering" as="element(x:range)*">
    <!-- returns a set of ranges covering offsets $start to $end
         on a given layer -->
    <xsl:param name="layer" as="element()"/>
    <xsl:param name="start" as="xs:integer"/>
    <xsl:param name="end" as="xs:integer"/>
    <!--<xsl:sequence select="key('ranges-starting-before',$start,$layer)
      intersect key('ranges-ending-after',$end,$layer)"/>-->
    <xsl:sequence select="$layer/x:range[
      ($start ge xs:integer(@start) and ($end le xs:integer(@end))) ]"/>
    <!-- if the attributes were bound to type xs:integer coming in,
         this could be faster? -->
  </xsl:function>

</xsl:stylesheet>
