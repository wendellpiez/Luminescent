<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://lmnl-markup.org/ns/luminescent/tokens"
  xmlns="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- tags LMNL syntax along delimiters indicated by 'token' markup -->

<!-- Sibling recursion assembles groups of delimiters and text together into tags. -->

  <xsl:template match="t:root">
    <root>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="/*/*[1]"/>
    </root>
  </xsl:template>
  
  <xsl:template match="t:d[. = ('[','{')]">
    <xsl:param name="depth" select="0" tunnel="yes"/>
    <xsl:variable name="end" as="element(t:d)?">
      <xsl:apply-templates select="following-sibling::*[1]" mode="find"/>
    </xsl:variable>
    <tag>
      <xsl:copy-of select="." copy-namespaces="no"/>
      <xsl:apply-templates select="following-sibling::*[1]
        [(. &lt;&lt; $end) or empty($end)]">
        <xsl:with-param name="stop" select="$end" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$end" copy-namespaces="no"/>
    </tag>
    <xsl:apply-templates select="$end/following-sibling::*[1]"/>
      <!--<xsl:with-param name="end" select="0" tunnel="yes"/>
    </xsl:apply-templates>-->
  </xsl:template>
  
  <xsl:template match="t:t | t:comment">
    <xsl:copy-of select="." copy-namespaces="no"/>
    <xsl:apply-templates select="following-sibling::*[1]"/>
  </xsl:template>
  
  <xsl:template match="t:d">
    <xsl:param name="stop" as="element(t:d)?" tunnel="yes"/>
    <xsl:if test="not(. is $stop)">
      <xsl:copy-of select="." copy-namespaces="no"/>
      <xsl:apply-templates select="following-sibling::*[1]"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:t | t:comment" mode="find">
    <xsl:apply-templates select="following-sibling::*[1]" mode="find"/>
  </xsl:template>
  
  <xsl:template match="t:d[. = ('[','{')]" mode="find">
    <xsl:param name="depth" select="0" tunnel="yes"/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="find">
      <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="t:d[. = (']','}')]" mode="find">
    <xsl:param name="depth" select="0" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$depth eq 0">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::*[1]" mode="find">
          <xsl:with-param name="depth" select="$depth - 1" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
</xsl:stylesheet>