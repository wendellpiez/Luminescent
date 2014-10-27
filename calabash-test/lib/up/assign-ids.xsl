<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- Assigns unique identifiers to ranges (both start and
       end tags) and annotations -->
  
  
  <xsl:key name="start-by-pID" match="start" use="@pID"/>
  
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="root | start | empty | annotation">
    <xsl:copy>
      <xsl:apply-templates select="." mode="id"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="end">
    <xsl:copy>
      <xsl:apply-templates select="key('start-by-pID',@pID)" mode="id"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- we're done with @pID, so we toss it -->
  <xsl:template match="@pID"/>
  
  <xsl:template match="start | empty" mode="id">
    <xsl:attribute name="rID" select="concat('R.',generate-id())"/>
  </xsl:template>
  
  <xsl:template match="root | annotation" mode="id">
    <!-- the root and annotations get layer IDs   -->
    <xsl:attribute name="lID" select="concat('N.',generate-id())"/>
  </xsl:template>
  
  
</xsl:stylesheet>