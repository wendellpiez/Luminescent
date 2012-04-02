<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  version="2.0"
  exclude-result-prefixes="x">
  
  <!-- xmlns="http://www.w3.org/1999/xhtml" -->

  <xsl:template match="/">
    <html xml:lang="en">
      <head>
        <title>Demonstrating LMNL</title>
        <meta charset="utf-8"/>
        <script type="text/javascript" src="jquery-1.7.1.min.js">
        <xsl:text> </xsl:text>
        </script>
        <script type="text/javascript">
$(document).ready(function() {
  $('.noteref').hover(
    function(event) {
      $('.'+this.id.replace(/^ref/,'noted')).addClass('highlight'); },
    function()
      {$('.'+this.id.replace(/^ref/,'noted')).removeClass('highlight')});
      
 $('.noteref').click(
    function(event) {
      $('.noted').each( function() { $(this).removeClass('on') } );
      $('.note').each( function() { $(this).removeClass('showing') } );
      $('.'+this.id.replace(/^ref/,'noted')).addClass('on');
      $('#'+this.id.replace(/^ref/,'note')).addClass('showing');
      });

 $('.note').click(
    function(event) {
      $(this).removeClass('showing');
      $('.'+this.id.replace(/^note/,'noted')).removeClass('on');
      });
});
        </script>
        <style type="text/css">
body > div { margin-left: 260px; padding: 20px; border: medium ridge black;
             background-color: lemonchiffon }
div > *:first-child { margin-top: 0px }
div > *:last-child { margin-bottom: 0px }
li, li > p { margin-top: 1ex; margin-bottom: 0px }
.noteref { font-weight: bold; color: darkred; background-color: lavender }
.on { background-color: peachpuff }
.note { display:block; width: 250px; left: 10px; margin-top: -10px; 
        background-color: peachpuff; border: thin solid darkred;
        float: left; clear: both; padding: 10px; font-size: 90%;
        position: absolute; visibility: hidden }
.showing { visibility: visible }
.highlight { background-color: lavender; text-decoration: underline }
      </style>
      </head>
      <body>
        <xsl:apply-templates/>
        <div style="display: none">
          <xsl:copy-of select="/"/>
        </div>
      </body>
    </html>
  </xsl:template>
  
 
  <xsl:template match="div">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="head">
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  
  <xsl:template match="p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  
  <xsl:template match="item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <xsl:template match="term">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>
  
  <xsl:template match="emph">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  
  <xsl:template match="link">
    <a href="{.}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="q">
    <xsl:text>&#8220;</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>&#8221;</xsl:text>
  </xsl:template>
  
  <xsl:template match="x:span">
    <xsl:apply-templates/>
  </xsl:template>
  
  
  <xsl:key name="notes-by-id" match="x:*[@name='noted']" use="@rID"/>
  
  <xsl:template match="x:span[exists(key('notes-by-id',tokenize(@ranges,'\s+')))]">
    <xsl:variable name="ids" select="for $n in key('notes-by-id',tokenize(@ranges,'\s+'))
      return replace($n/@rID,'\.','')"/>
    <span class="noted {for $id in distinct-values($ids) return concat('noted',$id)}">
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="x:*"/>
  
  <xsl:template match="x:start[@name='noted'] | x:empty[@name='noted']">
    <span class="note" id="note{replace(@rID,'\.','')}">
      <xsl:apply-templates select="." mode="ref"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="annotation-content"
        select="x:annotation[empty(@name)], x:annotation[@name='resp']"/>
    </span>
  </xsl:template>
  
  <xsl:template match="x:end[@name='noted'] | x:empty[@name='noted']">
    <span class="noteref" id="ref{replace(@rID,'\.','')}">
      <xsl:apply-templates select="key('notes-by-id',@rID)/(self::x:start|self::x:empty)" mode="ref"/>
    </span>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:start[@name='noted'] | x:empty[@name='noted']" mode="ref">
    <xsl:text>[</xsl:text>
    <xsl:number count="x:start[@name='noted'] | x:empty[@name='noted']" level="any"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="x:annotation[@name='resp']" mode="annotation-content">
    <xsl:text> [</xsl:text>
      <xsl:next-match/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="x:annotation" mode="annotation-content">
    <xsl:for-each select="x:content">
      <xsl:apply-templates />
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>