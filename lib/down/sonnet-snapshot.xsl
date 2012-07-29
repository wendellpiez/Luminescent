<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:u="http://www.lmnl.org/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="svg x u">

<xsl:variable name="specs">
  <background-color>none</background-color>
  <left-margin>40</left-margin>
  <top-margin>0</top-margin>
  <spacing>60</spacing>
  <title>
    <indent>40</indent>
    <drop>40</drop>
    <line-height>40</line-height>
    <font-size>24</font-size>
    <font-family>serif</font-family>
  </title>
  
</xsl:variable>
 
  <xsl:variable name="lmnl-document" select="/x:document"/>
  
  
  
  <xsl:variable name="ranges">
    <!--<arcs color="gainsboro" stroke="grey">
      <ranges>sonnet</ranges>
      <ranges>octave sestet</ranges>
      <ranges>quatrain tercet couplet</ranges>
      <ranges>line</ranges>
      <ranges>s</ranges>
      <ranges>phr</ranges>
    </arcs>-->
    <!--<circles color="lemonchiffon" fill-opacity="0.5" stroke="lightgreen" stroke-width="1" stroke-opacity="1">
      <ranges>octave sestet</ranges>
    </circles>-->
    <circles color="forestgreen" fill-opacity="0.5" stroke="forestgreen" stroke-width="1">
      <ranges>quatrain tercet couplet</ranges>
    </circles>
    <circles color="darkgreen" fill-opacity="0.4" stroke="darkgreen">
      <ranges>line</ranges>
    </circles>
    <circles color="aliceblue" fill-opacity="0.3" stroke="blue"
      stroke-width="1" stroke-opacity="0.4">
      <ranges>s</ranges>
    </circles>
    <circles color="aliceblue" fill-opacity="0.2" stroke="midnightblue"
      stroke-width="1" stroke-opacity="1">
      <ranges>phr</ranges>
    </circles>
  </xsl:variable>

  <xsl:key name="ranges-by-name" match="x:range" use="@name"/>
  
  <xsl:variable name="max-width"
    select="max($lmnl-document/x:range/@end)"/>
  
  <!--<xsl:variable name="max-height"
    select="count($ranges/boxes) * $specs/spacing"/>-->
  
  <xsl:variable name="full-height" select="80"/>
  
  <xsl:template match="/">
    <svg:svg width="{$max-width div 2}" height="{$full-height div 2}"
      viewBox="0 0 {$max-width} {$full-height}">
      
      <!--<svg:script type='text/ecmascript' xlink:href='smilScript.js' />-->
      
      <svg:rect x="0" y="0" width="100%" height="100%"
        style="stroke:none;fill:{$specs/background-color}"/>
      
      <!--<xsl:apply-templates select="$lmnl-document" mode="write-title"/>-->
      
      <svg:g transform="translate(400 {$full-height div 2})">
        <xsl:apply-templates select="$ranges/*" mode="draw"/>
          <!--<xsl:call-template name="drawButton"/>-->
      </svg:g>
    </svg:svg>
  </xsl:template>
  
  <xsl:template match="*" mode="draw">
    <xsl:variable name="figure" select="."/>
    <svg:g>
      <!--<svg:text>$lmnl-document is
        <xsl:value-of select="count($lmnl-document)"/>
      </svg:text>-->
      <xsl:for-each select="ranges/key('ranges-by-name',tokenize(current(),' '),$lmnl-document)">
          
        <xsl:variable name="length" select="@end - @start"/>
        <xsl:apply-templates select="$figure" mode="figure">
          <xsl:with-param name="range" select="."/>
        </xsl:apply-templates>
      </xsl:for-each>
    </svg:g>
  </xsl:template>
  
  <xsl:template match="boxes" mode="figure">
    <xsl:param name="range"/>
    <xsl:variable name="start-x" select="$range/@start - 400"/>
    <xsl:variable name="end-x" select="$range/@end - 400"/>
    <xsl:variable name="height" select="u:round(count(.|preceding-sibling::boxes) * ($full-height div count(../boxes)))"/>
    <xsl:variable name="style">
      <xsl:value-of select="concat('fill:',@color)"/>
      <xsl:value-of select="concat('; stroke:',(@stroke,'white')[1])"/>
      <xsl:value-of select="concat('; stroke-opacity:',(@stroke-opacity,'0.6')[1])"/>
      <xsl:value-of select="concat('; stroke-width:',(@stroke-width,'4')[1])"/>
      <xsl:value-of select="concat('; fill-opacity:',(@fill-opacity,'0.2')[1])"/>
    </xsl:variable>
    <svg:path style="{$style}"
      d="M {$start-x} {$height} L {$start-x} -{$height} L {$end-x} -{$height}  L {$end-x} {$height} Z"/>
  </xsl:template>
  
  <xsl:template match="circles" mode="figure">
    <xsl:param name="range"/>
    <xsl:variable name="start-x" select="$range/@start - 400"/>
    <xsl:variable name="end-x" select="$range/@end - 400"/>
    <xsl:variable name="radius" select="($end-x - $start-x) div 2"/>
    <xsl:variable name="center-x" select="$start-x + $radius"/> 
    <xsl:variable name="style">
      <xsl:value-of select="concat('fill:',@color)"/>
      <xsl:value-of select="concat('; stroke:',(@stroke,'white')[1])"/>
      <xsl:value-of select="concat('; stroke-opacity:',(@stroke-opacity,'0.6')[1])"/>
      <xsl:value-of select="concat('; stroke-width:',(@stroke-width,'2')[1])"/>
      <xsl:value-of select="concat('; fill-opacity:',(@fill-opacity,'0.2')[1])"/>
    </xsl:variable>
    <svg:circle style="{$style}" cx="{$center-x}" cy="0" r="{$radius}"/>
  </xsl:template>
  
  <xsl:template name="drawButton">
    <xsl:variable name="key-drop" select="30 * position()"/>
    <svg:rect fill="white" stroke="{@color}" stroke-width="2"
      rx="8" ry="6" width="20" height="16" y="{$key-drop}"
      id="{generate-id()}-on"/>
    <svg:rect fill="{@color}" fill-opacity="0.6"
      rx="8" ry="6" width="20" height="16" y="{$key-drop}" x="0"
      id="{generate-id()}-off" style="visibility:visible">
      <svg:set attributeName="visibility" attributeType="CSS" to="visible"
        begin="{generate-id()}-on.click" fill="freeze"/>
      <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
        begin="{generate-id()}-off.click" fill="freeze"/>
    </svg:rect>
    <svg:g transform="translate(30 {$key-drop})">
      <svg:text font-size="14" y="12">
        <xsl:for-each select="tokenize(string-join(ranges,' '),'\s')">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </svg:text>
    </svg:g>
  </xsl:template>

  <xsl:template match="x:lmnl-document" mode="write-title">
    <svg:g transform="translate({$specs/title/indent} {$specs/title/drop})">
      
      <xsl:for-each select="/*/*[@name='meta']/(*[@name='author'] , *[@name='title'])" >
        <svg:text y="{(position() - 1) * $specs/title/line-height}"
          font-family="{$specs/title/font-family}" font-size="{$specs/title/font-size}">
          <xsl:apply-templates/>
        </svg:text>
      </xsl:for-each>
      
    </svg:g>
  </xsl:template>
  
  <!--<xsl:template match="meta" mode="write-title">
    <svg:g font-family="{($specs/title/font-family,'serif')[1]}"
      font-size="{($specs/title/font-size,'serif')[1]}">
      <xsl:apply-templates select="author,title" mode="write-title"/>
    </svg:g>
  </xsl:template>-->
  
  <xsl:template match="text()">
    <xsl:value-of select="replace(.,'\s','&#xA0;')"/>
  </xsl:template>
  
  <xsl:function name="u:round">
    <xsl:param name="n"/>
    <xsl:value-of select="format-number($n,'0.000')"/>
  </xsl:function>
  
</xsl:stylesheet>