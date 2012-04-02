<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- assigns labels to start tags, for pairing end tags with them -->
  
  <xsl:template match="s:start">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <!-- pID marks a start tag for pairing; it will be tossed
           later when better range IDs are assigned -->
      <!-- An arbitrary (unique) identifier works well for this,
           and it's likely to be faster than counting -->
      <xsl:attribute name="pID" select="generate-id(.)"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="node()">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>