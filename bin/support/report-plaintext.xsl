<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="1.0">
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//report"/>
  </xsl:template>
  
  <xsl:template match="report">
    <xsl:text>&#xA;-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=</xsl:text>"
    <xsl:apply-templates select="incident"/>  
  </xsl:template>
  
  <xsl:template match="incident">
    <xsl:text>&#xA;</xsl:text>
    <xsl:variable name="code">
      <xsl:value-of select="@role"/>
      <xsl:if test="@role and @id">:</xsl:if>
      <xsl:value-of select="@id"/>
      </xsl:variable>
    <xsl:if test="normalize-space($code)">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$code"/>
      <xsl:text>] </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
</xsl:stylesheet>