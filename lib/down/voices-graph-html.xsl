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
    <background-color>darkred</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="lemonchiffon" opacity="0.2">voice</ranges>
      <ranges color="rosybrown" opacity="0.1">verse-para</ranges>
      <ranges color="darkorange" opacity="0.1">couplet tercet quatrain quintain sestet</ranges>
      <ranges color="gold" opacity="0.1" stroke="orange">q s</ranges>
      <ranges color="white" opacity="0.2">l lg</ranges>
      <ranges color="yellow" opacity="0.2">phr</ranges>
    </styles>
    <bars indent="10">
      <ranges width="30" indent="0">verse-para voice</ranges>
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
      <range>voice</range>
      <range label="left">phr</range>
      <range label="left">s</range>
    </discs>
  </xsl:variable>
  

  <xsl:variable name="page-css">
    <style type="text/css">
      div#text{
      margin-left:180px;
      color:white;
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
      color:gold
      }
      span.shine{
      background-color:lemonchiffon;
      color:darkgreen
      }
      rect.shine,
      circle.shine,
      path.shine {
      fill-opacity:0.5
      }</style>
  </xsl:variable>
  
  <xsl:template mode="display" match="l">
    <p class="line{ if (exists(@i)) then ' indent' else ''}">
      <xsl:apply-templates mode="display"/>
    </p>
  </xsl:template>
  
  <xsl:template mode="bubbleOffset" match="x:range[@name='voice']">
    <xsl:value-of select="count(x:covering(.,'voice')) * 50"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='voice']" mode="drawBubble">
    <xsl:param name="spec"  as="node()" tunnel="yes"/>
    <xsl:param name="style" as="node()" tunnel="yes"/>
    <xsl:variable name="start-y" select="@start"/>
    <xsl:variable name="end-y" select="@end"/>
    <xsl:variable name="radius" select="((@end - @start) div 2) + 1"/>
    
    <path id="bubble-{generate-id()}" class="range-bubble" fill="black" fill-opacity="0.2"
    d="M 0 {$start-y} L {$radius} {($end-y + $start-y) div 2} L 0 {$end-y}"  stroke="black" stroke-width="1" stroke-opacity="1"
      >
      <xsl:apply-templates select="." mode="assign-class">
        <xsl:with-param name="class">range-bubble</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="$style/@*" mode="copy-property"/>
      <xsl:attribute name="cx">
        <xsl:apply-templates select="." mode="bubbleOffset"/>
      </xsl:attribute>
    </path>
    <xsl:call-template name="label-disc">     
      <xsl:with-param name="radius" select="$radius"/>
      <xsl:with-param name="start-y" select="$start-y"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="x:range[@name='voice']" mode="label-disc">
    <xsl:value-of select="@name"/>
    <tspan font-size="60%">
      <xsl:value-of select="x:annotation[@name='who']/x:content/(concat(' (',string(.),')') )"/>
    </tspan>
  </xsl:template>
  
  <xsl:function name="x:covering" as="element(x:range)*">
    
    <xsl:param as="element(x:range)" name="who"/>
    <xsl:param as="xs:string+"       name="names"/>
    <xsl:sequence select="$who/../(x:range except $who)
      [@name=$names][(number(@start) le number($who/@start)) and (number(@end) ge number($who/@end)) ]"/>
  </xsl:function>
</xsl:stylesheet>