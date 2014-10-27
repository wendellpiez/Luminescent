<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- Does one thing: replaces @gi attributes with true
       generic identifiers by moving any range identifier
       value into a @label -->
  
  <!-- so <s:start gi="p"/> stays the same, while
       <s:start gi="p=q"/> becomes <s:start gi="p" label="q"/> -->
  
  <!-- FWIW, we are probably done with the label, but we'll keep
       it just in case we want it later -->
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="s:*/@gi[matches(.,'=')]">
    <xsl:attribute name="gi" select="replace(.,'=.*$','')"/>
    <xsl:attribute name="label" select="replace(.,'^.*=','')"/>
  </xsl:template>
  
</xsl:stylesheet>