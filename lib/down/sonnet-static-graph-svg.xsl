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
    <background-color>white</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>250</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="grey" opacity="0.05">sonnet octave sestet quatrain couplet</ranges>
      <ranges color="midnightblue" opacity="0.05">line</ranges>
      <ranges color="darkred" opacity="0.05" stroke-width="2">s</ranges>
      <ranges color="purple" opacity="0.05">phr</ranges>
    </styles>
    <bars indent="0">
      <ranges width="40">octave sestet quatrain couplet</ranges>
      <ranges width="20">line</ranges>
      <ranges indent="30" width="30">s</ranges>
      <ranges indent="30" width="20">phr</ranges>
    </bars>
    <discs indent="180">
      <range label="none">octave</range>
      <range label="none">sestet</range>
      <range label="none">quatrain</range>
      <range label="none">couplet</range>
      <range>line</range>
      <range label="left">s</range>
      <range label="left">phr</range>
    </discs>
    <text line="line" indent="140">
      <font-family>serif</font-family>
      <font-size>18</font-size>
      <font-color>black</font-color>
    </text>
  </xsl:variable>
  
</xsl:stylesheet>