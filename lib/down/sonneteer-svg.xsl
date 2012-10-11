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
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

  <xsl:import href="bubbles-svg.xsl"/>
  
  <xsl:variable name="specs">
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
      <ranges color="lavender" opacity="0.2">sonnet</ranges>
      <ranges color="skyblue">octave sestet</ranges>
      <ranges color="steelblue">quatrain tercet couplet</ranges>
      <ranges color="gainsboro" opacity="0.3">line</ranges>
      <ranges color="firebrick">s</ranges>
      <ranges color="orange">phr</ranges>
    </styles>
    <bars>
      <indent>150</indent>
      <ranges width="60" indent="0">octave sestet</ranges>
      <ranges width="60" indent="50">quatrain tercet couplet</ranges>
      <ranges width="60" indent="100">line</ranges>
      <ranges width="60" indent="150">phr</ranges>
      <ranges width="60" indent="200">s</ranges>
    </bars>
    <discs>
      <indent>100</indent>
      <range label="none">sonnet</range>
      <range label="none">octave</range>
      <range label="none">sestet</range>
      <range label="none">quatrain</range>
      <range label="none">couplet</range>
      <range>line</range>
      <range label="left">phr</range>
      <range label="left">s</range>
    </discs>
    <text line="l" div="verse-para">
      <indent>120</indent>
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