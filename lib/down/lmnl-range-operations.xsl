<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <!-- implements LMNL range relationship operations
    over an xLMNL document;
    should correspond to the spec at
    http://www.lmnl.org/wiki/index.php/Range_relationships -->
  
  <!-- note: ONLY WORKS ON RANGES IN THE SAME TEXT LAYER -->
  
  <xsl:function name="f:overlaps" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:overlaps-start($r1,$r2) or f:overlaps-end($r1,$r2)"/>
  </xsl:function>
  
  <xsl:function name="f:overlaps-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:starts-before-start($r1,$r2) and f:ends-before-end($r1,$r2)
      and not(f:precedes($r1,$r2))"/>
  </xsl:function>
  
  <xsl:function name="f:overlaps-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:starts-after-start($r1,$r2) and f:ends-after-end($r1,$r2)
      and not(f:follows($r1,$r2))"/>
  </xsl:function>
  
  <xsl:function name="f:precedes" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:ends-before-start($r1,$r2) or f:ends-with-start($r1,$r2)"/>
  </xsl:function>
  
  <xsl:function name="f:follows" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:starts-after-end($r1,$r2) or f:starts-with-end($r1,$r2)"/>
  </xsl:function>
  
  <xsl:function name="f:encloses" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="(f:starts-before-start($r1,$r2) or f:starts-with-start($r1,$r2))
      and (f:ends-after-end($r1,$r2) or f:ends-with-end($r1,$r2))
      and not(f:congrues-with($r1,$r2))"/>
  </xsl:function>
  
  <xsl:function name="f:fits-within" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="(f:starts-after-start($r1,$r2) or f:starts-with-start($r1,$r2))
      and (f:ends-before-end($r1,$r2) or f:ends-with-end($r1,$r2))
      and not(f:congrues-with($r1,$r2))"/>
  </xsl:function>
  
  <xsl:function name="f:congrues-with" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:starts-with-start($r1,$r2) and f:ends-with-end($r1,$r2)"/>
  </xsl:function>
  
  <xsl:function name="f:excludes" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:precedes($r1,$r2) or f:follows($r1,$r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-before-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) lt f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-after-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) gt f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-with-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) eq f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-before-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) lt f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-after-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) gt f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-with-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) eq f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-before-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) lt f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-after-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) gt f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:starts-with-end" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:start($r1) eq f:end($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-before-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) lt f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-after-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) gt f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:ends-with-start" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="f:end($r1) eq f:start($r2)"/>
  </xsl:function>
  
  <xsl:function name="f:start" as="xs:integer">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:value-of select="$r/@start"/>
  </xsl:function>
  
  <xsl:function name="f:end" as="xs:integer">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:value-of select="$r/@end"/>
  </xsl:function>
</xsl:stylesheet>