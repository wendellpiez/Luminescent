<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  exclude-result-prefixes="xs f"
  version="2.0">

<!-- Pre-indexes xLMNL format for BaseX:
  
  Expands offset and lengths to fixed length (whole number) representations
  (for BaseX range indexing)
  Cross-indexes ranges to spans
  -->
  
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="x:span"/>
  
  
<xsl:template match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates select="node() | @*"/>
  </xsl:copy>
</xsl:template>
  
  <xsl:variable name="format-string">
    <!-- if the longest range is 99, returns '01';
         if 87654, returns '00001' -->
         
    <!-- the longest string could be on the base layer or
         an annotation layer -->
    <xsl:variable name="max" select="max(//@end)"/>
    <xsl:value-of select="replace(translate(string($max),'01234567890','0000000000'),'0$','1')"/>
  </xsl:variable>
 
 <!-- This is now being done in tags-to-xLMNL.xsl
  
  <xsl:template match="x:span">
   <xsl:copy>
     <xsl:copy-of select="@*"/>
     <xsl:apply-templates select="." mode="id"/>
     <xsl:apply-templates/>
   </xsl:copy>
 </xsl:template>
  
 <xsl:template match="x:span" mode="id">
   <xsl:attribute name="ID">
     <xsl:value-of select="@layer"/>
     <xsl:text>-</xsl:text>
     <xsl:number/>
   </xsl:attribute>
 </xsl:template>

 <xsl:key name="spans-for-range" match="x:span" use="tokenize(@ranges,'\s+')"/>
  
  
  <xsl:template match="x:range">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="spans">
        <xsl:value-of separator=" ">
          <xsl:apply-templates select="key('spans-for-range',@ID)" mode="id"/>
        </xsl:value-of>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
 --> 
  
  <xsl:template match="@start | @end">
   <xsl:attribute name="{name(.)}">
     <xsl:value-of select="format-number(.,$format-string)"/>
   </xsl:attribute>
 </xsl:template>

</xsl:stylesheet>