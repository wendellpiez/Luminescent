<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:schold="http://www.ascc.net/xml/schematron"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tags"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:iso="http://purl.oclc.org/dsdl/schematron"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:template match="/*">
    <aggregated-report>
      <xsl:apply-templates/>
    </aggregated-report>
  </xsl:template>
    
  <xsl:template match="svrl:schematron-output" priority="2">
    <report>
      <xsl:copy-of select="@title"/>
      <xsl:apply-templates select="svrl:failed-assert | svrl:successful-report"/>
    </report>
  </xsl:template>
  
  <xsl:template match="svrl:failed-assert | svrl:successful-report">
    <incident>
      <xsl:copy-of select="@role | @id"/>
      <xsl:apply-templates/>
    </incident>
  </xsl:template>
  
  <xsl:template match="svrl:text">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  
</xsl:stylesheet>