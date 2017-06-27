<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://lmnl-markup.org/ns/luminescent/tags"
  xmlns="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- marks distinct spans of text with a stack of
       ranges in which they appear -->
  
  <xsl:template name="down" match="/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()[1]" mode="across"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="node()" mode="across" priority="-1">
    <xsl:param name="stack" select="()"/>
    <xsl:call-template name="down"/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="across">
      <xsl:with-param name="stack" select="$stack"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="span | comment | atom" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="ancestor::*[exists(@lID)][1]/@lID">
        <xsl:attribute name="layer" select="."/>
      </xsl:for-each>
      <xsl:if test="exists($stack)">
        <xsl:attribute name="ranges" select="string-join($stack,' ')"/>
      </xsl:if>
      <xsl:value-of select="self::span | self::comment"/>
      <xsl:apply-templates select="self::atom/node()[1]" mode="across"/>
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="across">
      <xsl:with-param name="stack" select="$stack"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="start" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:call-template name="down"/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="across">
      <xsl:with-param name="stack" select="$stack,string(@rID)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="end" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:call-template name="down"/>
    <!--<xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()[1]" mode="across"/>
    </xsl:copy>-->
    <xsl:apply-templates select="following-sibling::node()[1]" mode="across">
      <xsl:with-param name="stack" select="$stack[. ne current()/@rID]"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
</xsl:stylesheet>