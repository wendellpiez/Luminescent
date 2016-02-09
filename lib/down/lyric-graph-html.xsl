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

  <xsl:import href="bubbles-svg.xsl"/>

  <xsl:import href="xlmnl-xml.xsl"/>

  <xsl:output method="xhtml"/>

  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>0</left-margin>
    <top-margin>10</top-margin>
    <text-block-width>10</text-block-width>
    <bottom-margin>10</bottom-margin>
    <background-color>#003300</background-color>
    <title>
      <font-family>sans-serif</font-family>
      <font-size>18</font-size>
      <line-height>30</line-height>
      <indent>220</indent>
      <drop>30</drop>
    </title>
    <styles>
      <ranges color="rosybrown" opacity="0.1">verse-para</ranges>
      <ranges color="darkorange" opacity="0.1">quatrain tercet couplet tercet quatrain quintain</ranges>
      <ranges color="gold" opacity="0.1" stroke="orange">q s</ranges>
      <ranges color="white" opacity="0.2">l lg</ranges>
      <ranges color="yellow" opacity="0.2">phr</ranges>
    </styles>
    <bars indent="10">
      <ranges width="30" indent="0">verse-para</ranges>
      <ranges width="30" indent="30">lg quatrain tercet couplet quintain sestet</ranges>
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

  <xsl:template match="/">
    <html xml:lang="en">
      <head>
        <title>Lyric graph</title>
        <meta charset="utf-8"/>
        <script type="text/javascript" src="jquery-1.7.1.min.js">
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
        <xsl:copy-of select="$page-css"/>
      </head>
      <body style="background-color:{$specs/f:background-color}">
        <xsl:call-template name="bars-svg"/>
        <div id="text">
          <xsl:call-template name="display-lyric"/>
        </div>
        <xsl:call-template name="discs-svg"/>
        
        <!--<div style="display:none">
          <xsl:copy-of select="$lyric-xml"/>
        </div>-->
        
      </body>
    </html>
  </xsl:template>
  
  <xsl:variable name="page-css">
    <style type="text/css">
      div#text{
        margin-left:180px;
        color:white;
        font-size:12pt;
        width:320px
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
      span:hover{
        color:gold
      }
      span.shine{
        background-color:lemonchiffon;
        color:darkgreen
      }
      rect.shine,
      circle.shine{
        fill-opacity:0.5
      }</style>
  </xsl:variable>

  <xsl:template name="bars-svg">
    <svg width="{max($specs/f:bars/f:ranges/
      sum((@width,ancestor-or-self::*/@indent)))}"
      height="800" xmlns="http://www.w3.org/2000/svg"
      style="position:fixed; top: 0px">
      <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin})">
        <xsl:apply-templates select="/" mode="draw-bars"/>
      </g>
    </svg>
  </xsl:template>
  
  <xsl:template name="discs-svg">
    <svg width="624" height="800" xmlns="http://www.w3.org/2000/svg"
      style="position:fixed; top: 0px; left: 400px; z-index: -1">
      <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin})">
        <xsl:apply-templates select="/" mode="draw-discs"/>
      </g>
    </svg>
  </xsl:template>
  
  <xsl:variable name="lyric-xml">
    <xsl:apply-templates select="$lmnl-document">
      <xsl:with-param name="elements" tunnel="yes" as="xs:string*"
        select="('poem','meta','verse-para','sp','l')"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:template name="display-lyric">
    <!--<xsl:copy-of select="$sonnet-xml"/>-->
    <xsl:apply-templates select="$lyric-xml" mode="display"/>
  </xsl:template>

  <xsl:template mode="display" match="poem">
    <xsl:apply-templates mode="display"/>
  </xsl:template>

  <xsl:template mode="display" match="meta">
    <xsl:apply-templates select="@title,@author" mode="display"/>
  </xsl:template>
  
  <xsl:template mode="display" match="@title">
    <h3 class="title">
      <xsl:next-match/>
    </h3>
  </xsl:template>
  
  <xsl:template mode="display" match="@author">
    <h4 class="author">
      <xsl:next-match/>
    </h4>
  </xsl:template>
    
  <xsl:template mode="display" match="sonnet">
    <div class="lg">
      <xsl:apply-templates mode="display"/>
    </div>
  </xsl:template>
  
  <xsl:template mode="display" match="sp">
    <div class="sp">
      <xsl:apply-templates mode="display"/>
    </div>
  </xsl:template>
  
  <xsl:template mode="display" match="l">
    <p class="line">
      <xsl:apply-templates mode="display"/>
    </p>
  </xsl:template>
  
  <xsl:template mode="display" match="verse-para">
    <div class="{local-name()}">
      <xsl:apply-templates mode="display"/>
    </div>
  </xsl:template>
  
  <xsl:template match="l/x:span" mode="display">
    <span id="{generate-id(.)}"
      class="range-span {string-join(
      for $r in tokenize(@ranges,'\s+') return replace($r,'^R.','bar-'),' ')}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="x:*" mode="display"/>

  <xsl:template match="x:range[@name='sonnet']" mode="animate"
    xmlns="http://www.w3.org/2000/svg"/>

  <!-- customizes class assignment only on bubble objects
       generated for ranges, binding them to the corresponding bar. -->
  <xsl:template match="x:range" mode="assign-class">
    <xsl:param name="class"/>
    <xsl:if test="$class = 'range-bubble'">
      <xsl:attribute name="class" select="string-join(($class,replace(@ID,'^R\.','bar-')),' ')"/>
    </xsl:if>
  </xsl:template>

  <!-- suppressing labeling of discs 
  <xsl:template name="label-disc"/>-->

  <!--<xsl:template match="*" mode="animate" xmlns="http://www.w3.org/2000/svg">
    <xsl:param name="stroke-width" select="1" as="xs:double"/>
    <xsl:param name="fill-opacity" select="0.2" as="xs:double"/>
    <set attributeName="fill-opacity" to="{$fill-opacity + 0.1}"
      begin="{replace(@ID,'^R.','bar-')}.mouseover"/>
    <set attributeName="fill-opacity" to="{$fill-opacity}"
      begin="{replace(@ID,'^R.','bar-')}.mouseout"/>
    <xsl:for-each select="key('spans-by-range',@ID,$lyric-xml)">
      <set attributeName="fill-opacity" to="{$fill-opacity + 0.1}"
        begin="{generate-id(.)}.mouseover"/>
      <set attributeName="stroke-width" to="{$stroke-width * 2}"
        begin="{generate-id(.)}.mouseover"/>
      <set attributeName="fill-opacity" to="{$fill-opacity}"
        begin="{generate-id(.)}.mouseout"/>
      <set attributeName="stroke-width" to="{$stroke-width}"
        begin="{generate-id(.)}.mouseout"/>
    </xsl:for-each>
  </xsl:template>-->

</xsl:stylesheet>