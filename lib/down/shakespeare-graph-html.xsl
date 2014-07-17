<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all">

  <xsl:import href="sxLMNL-bubbles-svg.xsl"/>

  <!--<xsl:import href="xlmnl-xml.xsl"/>-->

  <xsl:param name="structured-lmnl" select="/x:document"/>
  
  <xsl:output method="xhtml"/>

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
      <ranges color="lavender" opacity="0.2">act</ranges>
      <ranges color="skyblue">scene</ranges>
      <ranges color="gold">sp</ranges>
      <!--<ranges color="lightgreen" opacity="0.3" line="gold" line-weight="10"
        line-opacity="0.8" width="10">story q</ranges>-->
    </styles>
    <bars indent="0">
      <ranges width="50">sp</ranges>
      <ranges width="60" indent="20">scene</ranges>
      <ranges width="60" indent="40">act</ranges>
    </bars>
    <discs indent="320">
      <range label="left">act</range>
      <range label="right">scene</range>
      <range label="left">sp</range>
    </discs>
  </xsl:variable>

  <xsl:key name="spans-by-rID" match="x:span" use="tokenize(@ranges,'\s+')"/>
  
  <xsl:template match="/">
    <html xml:lang="en">
      <head>
        <title>SQA graphic display</title>
        <meta charset="utf-8"/>
        <script type="text/javascript" src="jquery-1.9.1.min.js">
        <xsl:text> </xsl:text>
        </script>
        <xsl:comment> JQuery SVG plugin by Keith Wood: see keith-wood.name/svg.html (and thanks!) </xsl:comment>
        <script type="text/javascript" src="jquery.svg.min.js">
          <xsl:text> </xsl:text>
        </script>
        <script type="text/javascript" src="jquery.svgdom.min.js">
          <xsl:text> </xsl:text>
        </script>
        <!--<script type="text/javascript">
$(document).ready(function() {
  $('.range-bar').hover(
    function(event) {
      /* scroll to the corresponding span,
         found by @class=this.id */
      $('html, body').stop().animate({
            scrollTop: $('.'+this.id).offset().top - 50
        }, 1000);
        event.preventDefault();
      /* also, light it up */
      $('.'+this.id).addClass('shine');

      },
      function() {$('.'+this.id).removeClass('shine')});

});
        </script>-->
        <script type="text/javascript">
          
$(document).ready(function() {
          
  $('.range-bar').hover(
    function(event) {
    /* scroll to the corresponding span,
       found by @class=this.id */
      $('html, body').stop().animate(
        { scrollTop: $('.'+this.id).offset().top - 50 }, 1000);
      event.preventDefault();
    /* also, light it up */
    $('.'+this.id).stop(true,true).addClass('shine');
    },
    function() {$('.'+this.id).stop(true,true).removeClass('shine')
    }
  );

  $('.range-span').hover(
    function(event) {
      $.each($(this).attr('class').split(' '), function() {
        $('#' + this).addClass('shine') })
    },
    function() {
      $.each($(this).attr('class').split(' '), function() {
       $('#' + this).removeClass('shine') })
    }
  )
})
        </script>
        <style type="text/css">
div#text    { margin-left:150px; color: white; font-size: 12pt;
              width:430px }
div.scene      { margin-top: 2ex }
h3.title, h4.author { margin: 0px }
h3.title { border-bottom: thin solid white }
div.sp      { margin-top: 2ex }
div.speaker { font-weight: bold; font-size: 80% }
.stage { font-style: italic; font-size: 85% }
.stage .stage { font-size: inherit }
span.contd { padding-left: 6em }
// p.line      { margin-top: 0px; margin-bottom: 0px; margin-left: 1em; text-indent:-1em }
span.shine  { background-color: darkred }

rect.shine, circle.shine  { fill-opacity: 0.5 }
<!--
.range-bubble.on { fill-opacity: 0.4 }
.range-bubble.off { fill-opacity: 0.2 }-->
        </style>
      </head>
      <body style="background-color:{$specs/f:background-color}">
        <xsl:call-template name="bars-svg"/>

        <div id="text">
          <xsl:apply-templates select="$display-fragment"/>
        </div>
        <xsl:call-template name="discs-svg"/>
        
        <!--<div style="display:none">
          <xsl:copy-of select="$sonnet-xml"/>
        </div>-->
      </body>
    </html>
  </xsl:template>

 
  <xsl:template name="bars-svg">
    <xsl:variable name="width" select="max($specs/f:bars/f:ranges/sum((@width,ancestor-or-self::*/@indent)))"/>
    <svg xmlns="http://www.w3.org/2000/svg"
      width="{$width}" height="800"
      style="position:fixed; top: 0px">
      <g transform="translate({$specs/f:bars/@indent} {$specs/f:top-margin})">
        <xsl:apply-templates select="$display-fragment" mode="draw-bars"/>
      </g>
    </svg>
  </xsl:template>
  
  <xsl:template name="discs-svg">
    <svg xmlns="http://www.w3.org/2000/svg"
      width="624" height="800"
      style="position:fixed; top: 0px; left: 400px; z-index: -1">
      
      <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin})">
        <xsl:apply-templates select="$display-fragment" mode="draw-discs"/>
      </g>
    </svg>
  </xsl:template>


  <xsl:template match="x:annotation"/>
  
  <xsl:template match="x:div">
    <div class="{@name}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>  
  
  <xsl:template match="x:div[@name='scene']">
    <div class="scene">
      <xsl:call-template name="page-head"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>  
  
  <xsl:template name="page-head">
    <h4>
      <xsl:for-each select="(.|ancestor::x:div)/
        x:annotation[@name=('title','head')]">
        <xsl:if test="position() gt 1">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:comment> (empty) </xsl:comment>
      </xsl:for-each>
    </h4>
  </xsl:template>
  <!--<xsl:template match="l">
    <p class="line">
      <xsl:apply-templates/>
    </p>
  </xsl:template>-->
  
  <!--<xsl:template match="verse-para">
    <div class="{local-name()}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  -->
  <xsl:template match="x:annotation[@name='speaker']">
    <div class="speaker">
      <xsl:apply-templates/>
      <xsl:apply-templates select="following-sibling::x:empty[@name='stage'][x:annotation/@name='run-in']
        except following-sibling::x:span[normalize-space(.)]/following-sibling::*" mode="run-in"/>
    </div>
  </xsl:template>
  
  <xsl:template match="x:empty[@name='stage'][x:annotation/@name='run-in']" mode="#default" priority="3"/>
  
  <xsl:template match="x:empty[@name='stage'] | x:annotation[@name='stage']">
    <div class="stage">
      <xsl:apply-templates select="x:annotation[not(@name)] | x:annotation[@name='stage']"/>
    </div>
  </xsl:template>
  
  <xsl:template match="x:empty[@name='stage']" mode="run-in">
    <span class="stage">
      <xsl:apply-templates select="x:annotation[not(@name)] | x:annotation[@name='stage']"/>
    </span>
  </xsl:template>
  
  <xsl:template match="x:div[@name='sp']/x:empty[@name='stage']" priority="2">
    <span class="stage">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="x:annotation[not(@name)] | x:annotation[@name='stage']"/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="x:empty[@name='stage']/x:annotation[not(@name)] | x:annotation[@name='stage']/x:annotation[not(@name)]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="x:div[@name=('text','body','act','scene')]/x:span"/>
  
  <xsl:template match="x:span">
    <xsl:variable name="line" select="key('ranges-by-rID',tokenize(@ranges,'\s+'))[@name='line']"/>
    <xsl:variable name="contd" select="empty(preceding-sibling::x:span) and
      exists($line) and not(parent::x:div[@name='sp'] is $line/parent::x:div[@name='sp'])"/>
    <xsl:variable name="signals" select="key('ranges-by-rID',tokenize(@ranges,'\s+'))(: [@name='sp'] :)"/>
    <span id="{generate-id(.)}"
      class="range-span {string-join(
      for $rID in $signals/@rID return replace($rID,'^R.','bar-'),' ')}{' contd'[$contd]}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="x:start[@name='line'][exists(preceding-sibling::x:span[normalize-space()])]">
    <br class="lb"/>
  </xsl:template>
  
  <xsl:template match="x:div | x:start | x:empty" mode="assign-class">
    <xsl:param name="class"/>
    <xsl:if test="$class = 'range-bubble'">
      <xsl:attribute name="class" select="string-join(($class,replace(@rID,'^R\.','bar-')),' ')"/>
    </xsl:if>
  </xsl:template>
  
  <!--<xsl:template match="x:*"/>-->

  <!-- TODO: remove traces of mode 'animate' and 'animate-bubble' -->
  <xsl:template match="*" mode="animate animate-bubble"/>


 <!-- <xsl:template match="x:div | x:start" mode="animate-bubble"
    priority="2" xmlns="http://www.w3.org/2000/svg">
    <xsl:param name="stroke-width" select="1" as="xs:double"/>
    <xsl:param name="fill-opacity" select="0.2" as="xs:double"/>
    <set attributeName="class" to="range-bubble on"
      begin="{replace(@rID,'^R.','bar-')}.mouseover"/>
    <set attributeName="class" to="range-bubble off"
      begin="{replace(@rID,'^R.','bar-')}.mouseout"/>
    <xsl:next-match></xsl:next-match>
  </xsl:template>-->
  
  <!--<xsl:template match="x:div[@name='sp']" mode="animate-bubble" xmlns="http://www.w3.org/2000/svg">
    <xsl:param name="stroke-width" select="1" as="xs:double"/>
    <xsl:param name="fill-opacity" select="0.2" as="xs:double"/>
    <!-\-<set attributeName="fill-opacity" to="{ f:round(($fill-opacity + 1) div 2) }"
      begin="bar-{generate-id(.)}.mouseover"/>
    <set attributeName="stroke-width" to="{ f:round($stroke-width * 2) }"
      begin="bar-{generate-id(.)}.mouseover"/>
    <set attributeName="fill-opacity" to="{$fill-opacity}"
      begin="bar-{generate-id(.)}.mouseout"/>
    <set attributeName="stroke-width" to="{$stroke-width}"
      begin="bar-{generate-id(.)}.mouseout"/>-\->
    <xsl:for-each select="key('spans-by-rID',@rID,$structured-lmnl)">
      <set attributeName="class" to="range-bubble on"
        begin="{generate-id(.)}.mouseover"/>
      <set attributeName="class" to="range-bubble off"
        begin="{generate-id(.)}.mouseout"/>
    </xsl:for-each>
  </xsl:template>-->

  <!--<xsl:template match="x:start | x:end | x:empty"/>-->
</xsl:stylesheet>