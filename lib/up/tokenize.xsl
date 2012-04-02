<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://lmnl-markup.org/ns/luminescent/tokens"
  exclude-result-prefixes="xs"
  version="2.0">
  
<!-- Model for input:
  element t:root (
    attribute base-uri,
    (text |
    t:comment)* )
    
  Model for output:
  element t:root (
    attribute base-uri,
    (t:d |
    t:t |
    t:comment)* )
  
  where t:d tags LMNL syntax delimiters
  -->
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:comment">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="text()">  
      <xsl:variable name="delimiters" as="xs:string">\[\]{}</xsl:variable>
      <xsl:analyze-string select="." regex="[{$delimiters}]">
        <xsl:matching-substring>
          <t:d>
            <xsl:value-of select="."/>
          </t:d>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <t:t>
            <xsl:value-of select="."/>
          </t:t>   
        </xsl:non-matching-substring>
      </xsl:analyze-string>
  </xsl:template>
</xsl:stylesheet>