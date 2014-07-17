<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  exclude-result-prefixes="x">
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

  <xsl:import href="bubbles-svg.xsl"/>
  
  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>40</left-margin>
    <top-margin>10</top-margin>
    <bottom-margin>10</bottom-margin>
    <background-color>aliceblue</background-color>
    <title>
      <font-family>Cambria, serif</font-family>
      <font-size>36</font-size>
      <font-weight>bold</font-weight>
      <fill>midnightblue</fill>
      <fill-opacity>0.8</fill-opacity>
      <line-height>30</line-height>
      <indent>150</indent>
      <drop>60</drop>
    </title>
    <styles>
      <ranges color="midnightblue" opacity="0.2">act</ranges>
      <ranges color="darkred" opacity="0.2">scene</ranges>
      <ranges color="orange" opacity="0.2">prologue epilogue</ranges>
      <ranges color="darkgreen" opacity="0.2">sp</ranges>
      <ranges color="midnightblue" opacity="1" stroke-width="0.5">stage</ranges>
      <ranges color="steelblue">l line</ranges>
    </styles>
    <bars indent="20">
      <ranges width="25">act</ranges>
      <ranges width="30" indent="10">scene prologue epilogue</ranges>
      <ranges width="25" indent="20">stage</ranges>
      <ranges width="10" indent="45">sp</ranges>
    </bars>
    <discs indent="350">
      <range>act</range>
      <range label="left">scene</range>
      <range label="left">prologue</range>
      <range label="left">epilogue</range>
      <range>sp</range>
      <range>stage</range>
    </discs>
  </xsl:variable>
  
  <xsl:template name="display-meta-info">
    <g transform="translate({ $specs/f:title/f:indent } { $specs/f:title/f:drop })">
      <text>
        <xsl:for-each select="$specs/f:title/( f:font-family | f:font-size | f:fill | f:fill-opacity)">
          <xsl:attribute name="{name()}" select="string()"/>
        </xsl:for-each>
        <xsl:value-of select="$lmnl-document/x:range[@name='text']/x:annotation[@name='title']/x:content/string(.)"/>
      </text>
      
    </g>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('act','scene')]" mode="label-disc">
    <xsl:value-of select="x:annotation[@name='head']/x:content/string(.)"/>
  </xsl:template>
  
  <xsl:template mode="label-disc" priority="2"
    match="x:range[@name='sp']">
    <xsl:value-of select="x:annotation[@name='speaker']/x:content/string(.)"/>
  </xsl:template>
  
  <xsl:template mode="label-disc" priority="2"
    match="x:range[@name='stage'][matches(x:annotation[empty(@name)]/x:content/string(.),'^\p{Lu}')]">
    <xsl:text>&#xA0;</xsl:text>
    <xsl:value-of select="x:annotation[empty(@name)]/x:content/string(.)"/>
  </xsl:template>
  
  <xsl:template mode="label-disc" priority="1"
    match="x:range[@name='stage']"/>
  
</xsl:stylesheet>