<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all">
  
  <xsl:import href="bubbles-svg.xsl"/>
  
  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>40</left-margin>
    <top-margin>10</top-margin>
    <bottom-margin>10</bottom-margin>
    <background-color>midnightblue</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="lavender" opacity="0.2">verse-para</ranges>
      <ranges color="skyblue">lg</ranges>
      <ranges color="steelblue">l</ranges>
      <ranges color="pink" opacity="0.3"
        stroke="rosybrown" stroke-width="2"
        stroke-opacity="0.8">q</ranges>
    </styles>
    <bars indent="40">
      <ranges width="25" indent="-10">verse-para</ranges>
      <ranges width="10" indent="-15">lg</ranges>
      <ranges width="10" indent="-25">l</ranges>
      <ranges width="20" indent="10">q</ranges>
    </bars>
    <discs indent="200">
      <range label="left">verse-para</range>
      <range label="left">q</range>
      <range>lg</range>
      <range>l</range>
    </discs>
    <text line="l" div="verse-para" indent="120">
      <font-size>36</font-size>
      <font-color>lightsteelblue</font-color>
      <highlight ranges="q">pink</highlight>
    </text>
    <!--<buttons>
      <indent>160</indent>
      <drop>15</drop>
    </buttons>-->
  </xsl:variable>
  
  <xsl:template match="x:span[f:starting-ranges(.)/@name='verse-para']"
    mode="write" priority="5">
    <!-- verse-para starts are marked with pilcrows -->
    <xsl:if test="not(f:ranges(.)[@name='verse-para'] is key('ranges-by-name','verse-para',$lmnl-document)[1])">
      <svg:tspan> &#182; </svg:tspan>
    </xsl:if>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:span[f:ranges(.)/@name='emph']"
    mode="write" priority="4">
    <svg:tspan font-style="italic">
      <xsl:next-match/>
    </svg:tspan>
  </xsl:template>
  
  
  <xsl:template match="x:span[f:starting-ranges(.)/@name='q']" mode="format" priority="3">   
      <xsl:choose>
        <!-- unless the span starts a range not annotated as indirect, we get no mark -->
        <xsl:when test="empty(f:starting-ranges(.)[@name='q'][empty(x:annotation[@name='indirect'])])"/>
        <!-- use a single quote mark when this q is in a q -->
        <xsl:when test="(f:ranges(.) except f:starting-ranges(.))/@name='q'">
          <xsl:text>&#8216;</xsl:text>
        </xsl:when>
        <!-- otherwise use a double quote mark -->
        <xsl:otherwise>&#8220;</xsl:otherwise>
      </xsl:choose>
    
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:span[f:ending-ranges(.)/@name='q']"
    mode="format" priority="2">
    <xsl:next-match/>
      <xsl:choose>
        <!-- unless the span ends a range not annotated as indirect, we get no mark -->
        <xsl:when test="empty(f:ending-ranges(.)[@name='q'][empty(x:annotation[@name='indirect'])])"/>
        <!-- use a single quote mark when this q is in a q -->
        <xsl:when test="(f:ranges(.) except f:ending-ranges(.))/@name='q'">
          <xsl:text>&#8217;</xsl:text>
        </xsl:when>
        <!-- otherwise use a double quote mark -->
        <xsl:otherwise>&#8221;</xsl:otherwise>
      </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>