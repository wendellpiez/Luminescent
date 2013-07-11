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
    <background-color>skyblue</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="midnightblue" opacity="0.2">act</ranges>
      <ranges color="darkred" opacity="0.2">scene</ranges>
      <ranges color="darkgreen" opacity="0.2">prologue epilogue</ranges>
      <ranges color="gold" opacity="0.3">sp</ranges>
      <ranges color="steelblue">l line</ranges>
    </styles>
    <bars indent="20">
      <ranges width="25">act</ranges>
      <ranges width="30" indent="10">scene prologue epilogue</ranges>
      <ranges width="10" indent="45">sp</ranges>
    </bars>
    <discs indent="400">
      <range>act</range>
      <range>scene</range>
      <range>prologue</range>
      <range>epilogue</range>
      <range label="left">sp</range>
    </discs>
  </xsl:variable>
  
</xsl:stylesheet>