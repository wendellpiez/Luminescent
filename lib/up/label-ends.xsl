<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- assigns labels to end tags, using sibling recursion to match
       them with their proper start tags -->
  
  <xsl:template name="down" match="/s:root">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*[1]" mode="across"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="s:text" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="across">
      <xsl:with-param name="stack" select="$stack"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="*" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:call-template name="down"/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="across">
      <xsl:with-param name="stack" select="$stack"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:start" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:call-template name="down"/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="across">
      <xsl:with-param name="stack" select=".,$stack"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="s:end" mode="across">
    <xsl:param name="stack" select="()"/>
    <xsl:variable name="start" as="element(s:start)?">
      <!-- The assignment is permissive of errors, the assumption being
           that start/end mismatches should be identifies and trapped
           by other means; so this still runs even if there's no
           start tag for the end tag -->
      <!-- The start tag is identified as follows:
           - if we have no @gi, it is the first start tag in the stack
           with no @gi; or if the stack contains only a single start
           tag, and it is immediately preceding the end tag and
           we are inside a tag (start, end, empty or atom), we'll
           take it (this is for an abbreviated end annotation tag)
           - if we have a @gi, it is the first start tag in the stack
           with the same @gi
           -->
      <xsl:choose>
        <xsl:when test="empty(@gi)">
          <xsl:choose>
            <xsl:when test="($stack[1] is preceding-sibling::s:start[1])
              and empty($stack[1]/following-sibling::* intersect
                       (preceding-sibling::* except preceding-sibling::s:text))
              and exists(parent::s:start | parent::s:end | parent::s:empty | parent::s:atom)">
              <xsl:sequence select="$stack[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$stack[empty(@gi)][1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$stack[@gi = current()/@gi][1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*,$start/@pID"/>
      <xsl:apply-templates select="*[1]" mode="across"/>
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::*[1]" mode="across">
      <xsl:with-param name="stack" select="$stack[not(. is $start)]"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
</xsl:stylesheet>