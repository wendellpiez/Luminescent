<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://lmnl-markup.org/ns/luminescent/tags"
  xpath-default-namespace="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs"
  version="2.0">
  
<!-- 
    promotes matching pairs of start/end tags inside
    tags into annotations
-->

  <xsl:key name="end-by-pID" match="end" use="@pID"/>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!--<xsl:template match="/doc">
    <xsl:copy>
      <text>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </text>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template match="start | end | empty | atom">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*[1]" mode="annotate"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- 'annotate' mode picks up and promotes empties and start/end pairs into annotations -->
  
  <!-- comments inside tags are allowed -->
  <xsl:template match="comment" mode="annotate">
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>
  
  <!-- errors, encountered, warrant quitting -->
  <xsl:template match="error" mode="annotate">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- certain kinds of nodes are unexpected in this mode, so we capture them as errors -->
  <xsl:template match="end | atom | text[normalize-space(.)]" mode="annotate">
    <error code="{upper-case((self::*/local-name(.),'text')[1])}-UNEXPECTED">
      <xsl:copy-of select="@sl|@so|@el|@eo"/>
      <xsl:copy-of select="."/>
    </error>
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>
  
  <!-- text between annotations is dropped --> 
  <xsl:template match="text" mode="annotate">
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>
  
  <!--<!-\- in 'annotate' mode, we discard whitespace -\-> 
  <xsl:template match="text()[not(normalize-space(.))]" mode="annotate">
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>-->
  
  <!-- in 'annotate' mode, we simply proceed past comments and PIs --> 
  <xsl:template match="comment() | processing-instruction()" mode="annotate">
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>
  
  <!-- empty tags make annotations -->
  <xsl:template match="empty" mode="annotate">
    <annotation>
      <xsl:copy-of select="@*"/>
      <!-- contents of empty tags may become annotations -->
      <xsl:apply-templates select="*[1]" mode="annotate"/>
    </annotation>
    <!-- an empty tag may not indicate the last annotation, so we proceed -->
    <xsl:apply-templates select="following-sibling::*[1]" mode="annotate"/>
  </xsl:template>
  
  <!-- start tags should also make annotations -->
  <xsl:template match="start" mode="annotate">
    <xsl:variable name="end" select="key('end-by-pID',@pID)"/>
    <!-- the annotation's text layer includes everything up to
         but not including the end tag -->
    <annotation>
      <xsl:copy-of select="@*"/>
      <!-- @el and @eo mark the end position of a tag; we assign an
           annotation the @el and @eo of its end tag -->
      <xsl:copy-of select="$end/(@el|@eo)"/>
      <!-- the start tag might have its own annotations -->
      <xsl:apply-templates select="*[1]" mode="annotate"/>
      <xsl:choose>
        <xsl:when test="empty($end)">
          <error code="ANNOTATION-UNFINISHED">
            <xsl:copy-of select="@sl|@so|@el|@eo"/>
            <xsl:apply-templates select="following-sibling::*"/>
          </error>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates
              select="following-sibling::*
                      except $end/(.|following-sibling::node())"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- and the end tag for the annotation might have its
           own annotations :-> -->
      <xsl:apply-templates select="$end/*[1]" mode="annotate"/>
    </annotation>
    <!-- following the annotations we look for any more annotations -->
    <xsl:apply-templates select="$end/following-sibling::*[1]" mode="annotate"/>
  </xsl:template>

</xsl:stylesheet>