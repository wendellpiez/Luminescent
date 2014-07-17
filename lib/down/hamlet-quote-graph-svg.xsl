<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="svg x">
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

  <xsl:import href="bubbles-svg.xsl"/>
  
  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>40</left-margin>
    <top-margin>10</top-margin>
    <bottom-margin>10</bottom-margin>
    <background-color>none</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="black" opacity="0.1"
        stroke="black" stroke-width="1"
        stroke-opacity="1">phr s l</ranges>
    </styles>
    <bars indent="20">
      <ranges width="10">l</ranges>
      <ranges width="30">phr</ranges>
      <ranges width="30">s</ranges>
    </bars>
    <discs indent="240">
      <range label="left">s</range>
      <range label="left">phr</range>
      <range>l</range>
    </discs>
    <text line="l">
      <font-size>18</font-size>
      <font-family>serif</font-family>
      <font-color>black</font-color>
    </text>
  </xsl:variable>
  
</xsl:stylesheet>