<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://lmnl-markup.org/ns/luminescent/tokens"
  version="2.0">
  

  <!-- Annotates tokens with their line and character offsets -->

<xsl:template match="root">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="*[1]"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="t">
  <xsl:copy-of select="."/>
  <xsl:call-template name="next"/>
</xsl:template>

<xsl:template match="d | comment">
  <xsl:param tunnel="yes" name="l" select="1"/>
  <xsl:param tunnel="yes" name="o" select="1"/>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="l" select="$l"/>
    <xsl:attribute name="o" select="$o"/>
    <xsl:apply-templates select="node()[1]"/>
  </xsl:copy>
  <xsl:call-template name="next"/>
</xsl:template>    

<xsl:template name="next">
  <xsl:param tunnel="yes" name="l" select="1"/>
  <xsl:param tunnel="yes" name="o" select="1"/>
  <xsl:variable name="split" select="tokenize(.,'&#xA;')"/>
  <xsl:variable name="last" select="$split[last()]"/>
  <xsl:apply-templates select="following-sibling::*[1]">
    <xsl:with-param name="l" tunnel="yes" select="$l + (count($split) - 1)"/>  
    <xsl:with-param name="o" tunnel="yes" select="($o[count($split) eq 1],1)[1] + string-length($last)"/>
  </xsl:apply-templates>
</xsl:template>
  
</xsl:stylesheet>