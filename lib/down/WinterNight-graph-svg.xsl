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
    <background-color>darkgreen</background-color>
    <title>
      <font-family>serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="darkred" opacity="0.3">verse-para</ranges>
      <ranges color="darkorange" opacity="0.2">quatrain</ranges>
      <ranges color="gold" opacity="0.2">l</ranges>
      <ranges color="green" opacity="0.3"
        stroke="lightgreen" stroke-width="2"
        stroke-opacity="0.8">phr</ranges>
      <ranges color="olivedrab" opacity="0.3"
        stroke="gold" stroke-width="2"
        stroke-opacity="0.8">s</ranges>
    </styles>
    <bars indent="20">
      <ranges width="10">verse-para</ranges>
      <ranges width="10" indent="10">quatrain</ranges>
      <ranges width="10" indent="20">l</ranges>
      <ranges width="10" indent="30">phr</ranges>
      <ranges width="10" indent="40">s</ranges>
    </bars>
    <discs indent="120">
      <range label="left">s</range>
      <range label="left">phr</range>
      <range>l</range>
      <range>quatrain</range>
      <range>verse-para</range>
    </discs>
    <text line="l">
      <font-size>26</font-size>
      <font-color>tan</font-color>
    </text>
  </xsl:variable>
  
</xsl:stylesheet>