<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl.org/namespace/LMNL/xLMNL"
  xmlns:f="http://lmnl.org/namespace/XSLT/utility"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!-- A really evil routine for writing out LMNL syntax from a Reified LMNL document. -->

  <xsl:import href="lmnl-range-operations.xsl"/>  
  
  <xsl:strip-space elements="x:document x:range x:annotation"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="x:root/x:document" mode="write"/>
  </xsl:template>
  
  <xsl:key name="ranges-by-name" match="x:range" use="string(@name)"/>
  
  <xsl:key name="ranges-by-start" match="x:range" use="number(@start)"/>
  
  <xsl:key name="ranges-by-end" match="x:range" use="number(@end)"/>
  
  <xsl:template match="x:document | x:annotation" mode="write">
    <xsl:variable name="scope" select="."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:for-each select="for $c in string-to-codepoints(x:content) return codepoints-to-string($c)">
      <!-- iterating over the characters in the document or annotation -->
      <xsl:variable name="o" select="position() - 1"/>
      <!-- $o goes from 0 to the document length, less 1 -->
      <!-- first, write start tags for ranges starting with the character -->
      <xsl:apply-templates mode="start-tag"
        select="key('ranges-by-start',$o,$scope) intersect $scope/x:range">
        <!-- selecting the child ranges starting here -->
        <xsl:sort select="f:end(.) + 1" order="descending"/>
        <!-- sorting by end order, last first -->
      </xsl:apply-templates>
      <!-- now write the character -->
      <xsl:value-of select="."/>
      <!-- next, write end tags for ranges ending after the character,
           excluding empty ranges -->
      <xsl:apply-templates mode="end-tag"
        select="key('ranges-by-end',($o + 1),$scope)[not(@start = @end)] intersect $scope/x:range">
        <!-- selecting the child ranges ending here -->
        <xsl:sort select="f:start(.)" order="descending"/>
        <!-- sorting by start order, last first -->
        <xsl:sort select="position()" order="descending"/>
        <!-- secondary sort inverts document order of the ranges
             (so ranges end first which started later) -->
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="x:range" mode="start-tag">
    <xsl:variable name="scope" select=".."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:variable name="namesake-ranges"
      select="(key('ranges-by-name',@name,$scope) intersect $scope/x:range) except ."/>
    <xsl:variable name="mixed"
      select="exists($namesake-ranges[f:overlaps(.,current())])"/>
    <!-- test true if overlapping a range with the same name -->
    
    <xsl:if test="$mixed"> 
      <xsl:text>=</xsl:text>
      <xsl:value-of select="@ID"/>
    </xsl:if>
    <xsl:apply-templates select="x:annotation" mode="tag"/>
    <xsl:choose>
      <xsl:when test="@start = @end">
        <!-- the range is empty -->
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:range" mode="end-tag">
    <xsl:variable name="scope" select=".."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:text>{</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:variable name="namesake-ranges"
      select="(key('ranges-by-name',@name,$scope) intersect $scope/x:range) except ."/>
    <xsl:variable name="mixed"
      select="exists($namesake-ranges[f:overlaps(.,current())])"/>
    <!-- test true if overlapping a range with the same name -->
    <xsl:if test="$mixed">
      <xsl:text>=</xsl:text>
      <xsl:value-of select="@ID"/>
    </xsl:if>
    <xsl:text>]</xsl:text>
  </xsl:template>  
  
  <xsl:template match="x:annotation" mode="tag">
    <xsl:apply-templates select="." mode="start-tag"/>
    <xsl:if test="string(x:content)">
      <xsl:apply-templates select="." mode="write"/>
      <xsl:apply-templates select="." mode="end-tag"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="x:annotation" mode="start-tag">
    <xsl:text> [</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:apply-templates select="x:annotation" mode="tag"/>
    <xsl:choose>
      <xsl:when test="not(string(x:content))">
        <!-- we're empty -->
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="x:annotation" mode="end-tag">
    <xsl:text>{</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>]</xsl:text>
  </xsl:template>  
  
  
</xsl:stylesheet>
