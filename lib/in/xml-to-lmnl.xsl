<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:apply-templates mode="write"/>
  </xsl:template>
  
  <xsl:template match="*" mode="write">
    <xsl:apply-templates mode="start-tag" select="."/>
    <xsl:if test="exists(node())">
    <xsl:apply-templates mode="write"/>
    <xsl:apply-templates mode="end-tag" select="."/>
    </xsl:if>
  </xsl:template>
  
  
  <xsl:template match="text()" mode="write">
    <xsl:value-of select="f:lmnl-escape(.)"/>
  </xsl:template>
  
  <xsl:template match="comment()" mode="write">
    <xsl:text>[!--</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--]</xsl:text>
  </xsl:template>
  
  <xsl:template match="/processing-instruction()" mode="write">
    <xsl:text>[!--!</xsl:text>
    <xsl:value-of select="string-join((name(),.),' ')"/>
    <xsl:text>--]&#xA;</xsl:text>
  </xsl:template>
  
  <xsl:template match="processing-instruction()" mode="write">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:if test="string(.)">
      <xsl:text> [}</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>{]</xsl:text>
    </xsl:if>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  
  <xsl:template match="*" mode="start-tag">
    <xsl:variable name="scope" select=".."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:text>[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="tag"/>
    <xsl:choose>
      <xsl:when test="empty(node())">
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="end-tag">
    <xsl:text>{</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>]</xsl:text>
  </xsl:template>  
  
  <xsl:template match="@*" mode="tag">
    <xsl:if test="position()=1">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>}</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>{]</xsl:text>
  </xsl:template>

  <xsl:function name="f:lmnl-escape" as="xs:string">
    <xsl:param name="t" as="text()"/>
    <xsl:value-of>
    <xsl:analyze-string select="$t" regex="[\[\{{\]\}}]">
      <xsl:matching-substring>
        <xsl:variable name="chs" as="element()+">
          <f:char name="lsqb" v="["/>
          <!-- These are LREs, so ATVs are recognized -->
          <f:char name="lcub" v="{{"/>
          <f:char name="rcub" v="}}"/>
          <f:char name="rsqb" v="]"/>
        </xsl:variable>
        <xsl:apply-templates select="$chs[@v=regex-group(0)]"/>
      </xsl:matching-substring>
      
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
    </xsl:value-of>
  </xsl:function>
  
  <xsl:template match="f:char">
    <xsl:text>{{lmnl:</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  
  </xsl:stylesheet>
