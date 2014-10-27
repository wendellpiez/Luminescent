<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs s"
  version="2.0">
  
  <!-- sibling recursion to mark tags with their offsets -->
  
  <xsl:template match="s:*">
    <xsl:param name="offset" select="0" as="xs:integer"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- we mark start, end and empty elements with their offsets -->
      <xsl:for-each select="self::s:start | self::s:end | self::s:empty">
        <xsl:attribute name="off" select="$offset"/>
      </xsl:for-each>
      <xsl:apply-templates select="node()[1]"/>
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node()[1]">
      <xsl:with-param name="offset" select="$offset"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:atom">
    <xsl:param name="offset" select="0" as="xs:integer"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="off" select="$offset"/>
      <xsl:apply-templates select="node()[1]"/>
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node()[1]">
      <xsl:with-param name="offset" select="$offset + 1"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:comment">
    <xsl:param name="offset" select="0" as="xs:integer"/>
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::node()[1]">
      <xsl:with-param name="offset" select="$offset"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:text" priority="0">
    <xsl:param name="offset" select="0" as="xs:integer"/>
    <span off="{$offset}" xmlns="http://lmnl-markup.org/ns/luminescent/tags">
      <xsl:value-of select="."/>
    </span>
    <xsl:apply-templates select="following-sibling::node()[1]">
      <xsl:with-param name="offset" select="$offset + string-length(.)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="node()">
    <!-- by default, continue to count forward without accruing -->
    <xsl:param name="offset" select="0" as="xs:integer"/>
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::node()[1]">
      <xsl:with-param name="offset" select="$offset"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
</xsl:stylesheet>