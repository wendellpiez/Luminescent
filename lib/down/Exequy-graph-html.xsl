<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<!-- TODO: consolidate this stylesheet with sonneteer-graph.xsl (which is largely identical) -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all">

  <xsl:import href="lyric-graph-html.xsl"/>

  <xsl:output method="xhtml"/>

  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>0</left-margin>
    <top-margin>10</top-margin>
    <text-block-width>10</text-block-width>
    <bottom-margin>10</bottom-margin>
    <background-color>white</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="rosybrown" opacity="0.2">verse-para</ranges>
      <ranges color="darkorange" opacity="0.2">couplet tercet quatrain quintain sestet</ranges>
      <ranges color="gold" opacity="0.2" stroke="orange">q s</ranges>
      <ranges color="darkgrey" opacity="0.4">l lg</ranges>
      <ranges color="indianred" opacity="0.4">phr</ranges>
    </styles>
    <bars indent="10">
      <ranges width="30" indent="0">verse-para</ranges>
      <ranges width="30" indent="30">lg couplet tercet quatrain quintain sestet</ranges>
      <ranges width="30" indent="60">l</ranges>
      <ranges width="30" indent="90">phr</ranges>
      <ranges width="30" indent="105">s q</ranges>
    </bars>
    <discs indent="220">
      <range label="none">verse-para</range>
      <range label="none">q</range>
      <range label="none">sestet</range>
      <range label="none">quintain</range>
      <range label="none">quatrain</range>
      <range label="none">tercet</range>
      <range label="none">couplet</range>
      <range>l</range>
      <range label="left">phr</range>
      <range label="left">s</range>
    </discs>
  </xsl:variable>
  

  <xsl:variable name="page-css">
    <style type="text/css">
      div#text{
      margin-left:180px;
      color:black;
      font-size:12pt;
      width:400px
      }
      div.verse-para{
      margin-top:2ex
      }
      h3.title,
      h4.author{
      margin:0px
      }
      h3.title{
      border-bottom:thin solid white
      }
      div.lg{
      margin-top:2ex
      }
      p.line{
      margin-top:0px;
      margin-bottom:0px;
      padding-left:1em;
      text-indent:-1em
      }
      p.indent { padding-left: 3em }
      span:hover{
      text-decoration: underline
      }
      span.shine{
      background-color: gainsboro
      }
      rect.shine,
      circle.shine{
      fill-opacity:0.5
      }</style>
  </xsl:variable>
  
  <xsl:template mode="display" match="l">
    <p class="line{ if (exists(@i)) then ' indent' else ''}">
      <xsl:apply-templates mode="display"/>
    </p>
  </xsl:template>
  
</xsl:stylesheet>