<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- Newly revised to take advantage of span elements in new xLMNL model. -->

  <xsl:import href="lmnl-range-operations.xsl"/>  
  
  <xsl:strip-space elements="x:document x:range x:annotation x:content"/>
  
  <xsl:template match="/">
    <lmnl>
      <xsl:apply-templates select="x:document" mode="write"/>
    </lmnl>
  </xsl:template>
  
  <xsl:key name="ranges-by-name" match="x:range" use="string(@name)"/>
  
  <xsl:key name="ranges-by-start" match="x:range" use="number(@start)"/>
  
  <xsl:key name="ranges-by-end" match="x:range" use="number(@end)"/>
  
  <xsl:template match="x:document | x:annotation" mode="write">
    <xsl:variable name="scope" select="."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:for-each select="x:content/x:span">
      <xsl:variable name="start" select="@start"/>
      <xsl:variable name="end" select="@end"/>
      <!--<xsl:if test="position() eq 1">
        <!-\- since this stylesheet handles fragmentary xLMNL (that is,
             xLMNL where ranges may cover more than the given content),
             we have to write start tags for any ranges that have started
             before the first span's start -\->
        <xsl:apply-templates mode="start-tag"
          select="$scope/x:range[@start lt $start]">
          <xsl:with-param name="content-start" select="$start"/>
          <xsl:sort select="f:end(.) + 1" order="descending"/>
        </xsl:apply-templates>
      </xsl:if>-->
      
      <!-- This serializer can handle fragments, including potentially
           fragments with gaps. If a gap is found between spans,
           we write an atom out to indicate it. -->
      <!--<xsl:if test="@start &gt; preceding-sibling::x:span[1]/@end">
        <xsl:call-template name="mark-gap">
          <xsl:with-param name="length" select="@start - preceding-sibling::x:span[1]/@end"/>
        </xsl:call-template>
      </xsl:if>-->

      <!-- write start tags for ranges starting with the span -->
      <xsl:apply-templates mode="start-tag"
        select="$scope/x:range[@start eq $start]">
        <!-- selecting the child ranges starting here -->
        <xsl:sort select="f:end(.) + 1" order="descending"/>
        <!-- sorting by end order, last first -->
      </xsl:apply-templates>
      <!-- now write the span's content -->
      <xsl:apply-templates select="." mode="value"/>
      <!-- next, write end tags for ranges ending after the character,
           excluding empty ranges -->
      <xsl:apply-templates mode="end-tag"
        select="$scope/x:range[@end eq $end and not(@end eq @start)]">
        <!-- selecting the child ranges ending here -->
        <xsl:sort select="f:start(.)" order="descending"/>
        <!-- sorting by start order, last first -->
        <xsl:sort select="position()" order="descending"/>
        <!-- secondary sort inverts document order of the ranges
             (so ranges end first which started later) -->
      </xsl:apply-templates>
      <!--<xsl:if test="position() eq last()">
        <!-\- now write end tags for any ranges that have ended
             after the last span's end -\->
        <xsl:apply-templates mode="end-tag"
          select="$scope/x:range[@end gt $end]">
          <xsl:with-param name="content-end" select="$end"/>
          <xsl:sort select="f:start(.)" order="descending"/>
        </xsl:apply-templates>
      </xsl:if>-->
      
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="x:range" mode="start-tag">
    <xsl:param name="content-start" select="@start"/>
    <xsl:variable name="scope" select=".."/>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:call-template name="add-id"/>
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
    <xsl:if test="($content-start lt @start) and (following-sibling::x:range[1]/@start &gt; @start)">
      <xsl:call-template name="mark-gap">
        <xsl:with-param name="length" select="following-sibling::x:range/@start - @start"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add-id">
    <xsl:variable name="namesake-ranges" select="f:ilk(.)"/>
    <xsl:variable name="mixed" select="exists($namesake-ranges[f:overlaps(.,current())])"/>
    <!-- test true if overlapping a range with the same name -->
    <xsl:if test="$mixed">
      <xsl:text>=</xsl:text>
      <xsl:value-of select="@ID"/>
    </xsl:if>
  </xsl:template>  
  
  
  <xsl:template match="x:range" mode="end-tag">
    <xsl:param name="content-end" select="@end"/>
    <xsl:variable name="scope" select=".."/>
    <xsl:if test="($content-end gt @end) and (preceding-sibling::x:range[1]/@end &lt; @end)">
      <xsl:call-template name="mark-gap">
        <xsl:with-param name="length" select="@end - preceding-sibling::x:range/@end"/>
      </xsl:call-template>
    </xsl:if>
    <!-- the scope of range retrieval is the document or annotation -->
    <xsl:text>{</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:call-template name="add-id"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template name="mark-gap">
    <xsl:param name="length" select="0"/>
    <xsl:text>{{gap [length}</xsl:text>
    <xsl:value-of select="$length"/>
    <xsl:text>{]}}</xsl:text>
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
  
  <xsl:template match="x:atom" mode="value">
    <xsl:text>{{</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:apply-templates select="x:annotation" mode="tag"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <xsl:template match="x:comment" mode="value">
    <xsl:text>[!-- </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--]</xsl:text>
  </xsl:template>
  
  <xsl:function name="f:ilk" as="element(x:range)*">
    <!-- returns all ranges in the same layer with the same name as $range -->
    <xsl:param name="range" as="element(x:range)"/>
    <xsl:variable name="range-name" select="f:range-name($range)"/>
    <xsl:sequence select="$range/../x:range[f:range-name(.) eq $range-name] except $range"/>
  </xsl:function>

  <xsl:function name="f:range-name" as="xs:string">
    <xsl:param name="range" as="element(x:range)"/>
    <xsl:value-of select="($range/@name,'[ANONYMOUS]')[1]"/>
  </xsl:function>
  
    
</xsl:stylesheet>
