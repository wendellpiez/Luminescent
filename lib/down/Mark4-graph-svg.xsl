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
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

<xsl:param name="title" select="''"/>
  
<xsl:variable name="specs">
  <background-color>cornsilk</background-color>
  <left-margin>2</left-margin>
  <baseline>220</baseline>
  <scale>1</scale>
  <squash>1</squash>
  <zoom>1</zoom>
  <expand>1</expand>
  <title>
    <indent>40</indent>
    <drop>40</drop>
    <line-height>40</line-height>
    <font-size>24</font-size>
    <font-family>sans-serif</font-family>
  </title>
</xsl:variable>

  <xsl:param name="scale" select="($specs/scale,1)[1]"/>
  
  <xsl:param name="expand" select="($specs/expand,1)[1]"/>
  
  <xsl:param name="doctype" select="''"/>
  
  <xsl:variable name="ranges">
      <arcs fill="red" fill-opacity="0.4"
          stroke="darkred" stroke-width="0.1" stroke-opacity="0.5">
          <ranges>verse</ranges>
        </arcs>
        <arcs fill="gold" fill-opacity="0.4"
          stroke="darkorange" stroke-width="0.1" stroke-opacity="0.5">
          <ranges>q</ranges>
        </arcs>
<!--        <arcs fill="green" fill-opacity="0.4"
          stroke="darkgreen" stroke-width="0.1" stroke-opacity="0.5">
          <ranges>green</ranges>
        </arcs>
-->    
  </xsl:variable>
  
  <xsl:variable name="lmnl-document" select="/x:document"/>
  
  <xsl:key name="ranges-by-name" match="x:range" use="@name"/>
  
  <xsl:variable name="max-height"
    select="max(for $r in (/*/x:range) return ($r/@end - $r/@start)) * $specs/squash"/>
  
  <xsl:template match="/">
    <svg:svg width="800" height="300"
      onload="InitSMIL(evt)"
      viewBox="0 0 {u:round(800 * $specs/zoom)} {u:round(300 * $specs/zoom)}">
      
      <!--viewBox="0 0 {u:round(800 * $zoom)} {u:round(600 * $zoom)}">-->
      <!--<svg:script type='text/ecmascript' xlink:href='smilScript.js' />-->
      
      <!--<svg:rect x="0" y="0" width="100%" height="100%"
        style="stroke:none;fill:{$specs/background-color}"/>-->
      
      
      
      <svg:g transform="translate({$specs/left-margin} {$specs/baseline})">
        <xsl:for-each select="$ranges/arcs">
          <!--<xsl:call-template name="drawButton"/>-->
          <xsl:call-template name="drawArcs"/>
        </xsl:for-each>
        
        <xsl:for-each select="$lmnl-document/x:content/x:span">
          
          <xsl:variable name="start-x" select="@start * $expand"/>
          <xsl:variable name="end-x" select="@end * $expand"/>
          <xsl:variable name="length" select="@end - @start"/>
          <xsl:variable name="height" select="u:round($length * $specs/squash)"/>
          <svg:text font-size="1" y="-1"
            x="{($start-x + $end-x) div 2}" text-anchor="middle"
            font-family="monospace">
            <xsl:value-of select="."/>
          </svg:text>
        </xsl:for-each>
      </svg:g>
      
      
    </svg:svg>
  </xsl:template>
  
  <xsl:template name="drawArcs">
    <xsl:variable name="arc" select="."/>
    <svg:g style="visibility:visible" transform="scale({$scale})">
      <!--<svg:set attributeName="visibility" attributeType="CSS" to="visible"
        begin="{generate-id()}-on.click" fill="freeze"/>
      <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
        begin="{generate-id()}-off.click" fill="freeze"/>-->
      <xsl:for-each select="ranges">
        <xsl:for-each
          select="key('ranges-by-name',tokenize(current(),'\s+'),$lmnl-document)">
          <xsl:variable name="start-x" select="@start * $expand"/>
          <xsl:variable name="end-x" select="@end * $expand"/>
          <xsl:variable name="length" select="@end - @start"/>
          <xsl:variable name="height" select="u:round($length * $specs/squash)"/>
          <svg:path d="M {$start-x} 0 C {$start-x} -{$height} {$end-x} -{$height} {$end-x} 0">
            <!-- copying style properties from the arc -->
            <xsl:copy-of select="$arc/@*"/>
          </svg:path>
          <!--<svg:text font-size="2" y="-{$height div 2}"
            x="{($start-x + $end-x) div 2}" text-anchor="middle">
            <xsl:copy-of select="$arc/@*"/>
            <xsl:value-of select="@name"/>
          </svg:text>-->
        </xsl:for-each>
      </xsl:for-each>
    </svg:g>
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
        <xsl:for-each select="tokenize(string-join(ranges,' '),'\s+')">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </svg:text>
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