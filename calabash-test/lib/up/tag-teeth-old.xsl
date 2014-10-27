<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tokens"
  xmlns="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="s xs"
  version="2.0">
  
  <!-- tags LMNL syntax along delimiters indicated by 'token' markup -->

<!-- input example:

<s:root xmlns:s="http://lmnl-markup.org/ns/luminescent/tokens"><s:d>[</s:d><s:t>zoo</s:t><s:d>}</s:d><s:t>
</s:t><s:d>[</s:d><s:t>empty </s:t><s:d>[</s:d><s:t>e</s:t><s:d>}</s:d><s:t>1</s:t><s:d>{</s:d><s:t>e</s:t><s:d>]</s:d><s:t> </s:t><s:d>[</s:d><s:t>test</s:t><s:d>}</s:d><s:t>TEST ME</s:t><s:d>{</s:d><s:d>]</s:d><s:d>]</s:d><s:t>
</s:t><s:d>[</s:d><s:t>excerpt </s:t><s:d>[</s:d><s:t>source</s:t><s:d>}</s:d><s:t>The </s:t><s:d>[</s:d><s:t>n=n1</s:t><s:d>}</s:d><s:t>Housekeeper</s:t><s:d>{</s:d><s:t>source</s:t><s:d>]</s:d><s:t> </s:t><s:d>[</s:d><s:t>author</s:t><s:d>}</s:d><s:t>Robert Frost</s:t><s:d>{</s:d><s:t>author</s:t><s:d>]</s:d><s:d>}</s:d><s:t>
...

     output example:
     
<root xmlns="http://lmnl-markup.org/ns/luminescent/tags"><tag>[zoo}</tag>
<tag>[empty <tag>[e}</tag>1<tag>{e]</tag> <tag>[test}</tag>TEST ME<tag>{]</tag>]</tag>
<tag>[excerpt <tag>[source}</tag>The <tag>[n=n1}</tag>Housekeeper<tag>{source]</tag> <tag>[author}</tag>Robert Frost<tag>{author]</tag>}</tag>
...

This is achieved using sibling recursion to assemble groups of delimiters and text together into tags.

-->

  <xsl:template name="start" match="/">
    <root>
      <xsl:apply-templates select="/*/*[1]" mode="push"/>
    </root>
  </xsl:template>
  
  <xsl:template match="s:d[. = ('[','{')]" mode="push">
    <xsl:param name="depth" select="0" tunnel="yes"/>
    <tag>
      <xsl:apply-templates/>
      <xsl:apply-templates select="following-sibling::*[1]" mode="push">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </tag>
    <xsl:apply-templates select="following-sibling::*[1]" mode="pop">
      <xsl:with-param name="from" select="$depth" tunnel="yes"/>
      <xsl:with-param name="depth" select="$depth" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:t" mode="push">
    <!-- removing whitespace-only leaders or trailers, silently -->
    <xsl:if test="normalize-space(.) or
      (exists(preceding-sibling::*) and exists(following-sibling::*))">
      <xsl:apply-templates/>
      <xsl:apply-templates select="following-sibling::*[1]" mode="push"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="s:d[. = (']','}')]" mode="push">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="s:d[. = ('[','{')]" mode="pop">
    <xsl:param name="depth" required="yes" tunnel="yes"/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="pop">
      <!--<xsl:with-param name="from" select="$depth"/>-->
      <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:t" mode="pop">
    <xsl:apply-templates select="following-sibling::*[1]" mode="pop"/>
  </xsl:template>
  
  <xsl:template match="s:d[. = (']','}')]" mode="pop">
    <xsl:param name="depth" required="yes" tunnel="yes"/>
    <xsl:param name="from" required="yes" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$depth eq $from">
        <xsl:apply-templates select="following-sibling::*[1]" mode="push"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::*[1]" mode="pop">
          <xsl:with-param name="depth" select="$depth - 1" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
</xsl:stylesheet>