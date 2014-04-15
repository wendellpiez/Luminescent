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
    <background-color>#303063</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="lavender" opacity="0.2">preface introduction chapter div verse-para</ranges>
      <ranges color="skyblue">lg verse</ranges>
      <ranges color="steelblue">l line</ranges>
      <ranges color="thistle" opacity="0.1">letter entry</ranges>
      <ranges color="pink">story</ranges>
      <ranges color="lightgreen" opacity="0.3" stroke="gold" stroke-width="2"
        stroke-opacity="0.8">q</ranges>
      <ranges color="green" opacity="0.3">p</ranges>
    </styles>
    <bars indent="20">
      <ranges width="30" indent="20">story</ranges>
      <ranges width="30">chapter</ranges>
      <ranges width="10" indent="45">q</ranges>
    </bars>
    <discs indent="400">
      <range>preface</range>
      <range>introduction</range>
      <range label="left">story</range>
      <range>letter</range>
      <range>entry</range>
      <range>chapter</range>
      <range label="left">p</range>
      <range label="left">q</range>
    </discs>
  </xsl:variable>
  
</xsl:stylesheet>