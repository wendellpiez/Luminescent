<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

  <xsl:import href="bubbles-svg.xsl"/>

  <xsl:param name="LMNL-file" as="xs:string"/>
  
  <xsl:param name="labels" select="'yes'"/>
  
  <xsl:param name="source" select="'no'"/>
  
  <xsl:variable name="show-labels" select="$labels = 'yes'"/>
  <xsl:variable name="show-source" select="$source = 'yes'"/>
  
  <xsl:variable name="LMNL-literal">
    <xsl:value-of select="f:eol(unparsed-text($LMNL-file,'utf-8'))"/>
  </xsl:variable>
  
  <xsl:template match="/">
    <svg width="1000" height="600" viewPort="0 0 1200 600">
      <xsl:call-template name="draw-svg"/>
    </svg>
  </xsl:template>
  
  
                      <!-- xmlns:f="http://lmnl-markup.org/ns/xslt/utility" -->
  <xsl:variable name="specs" xmlns="http://lmnl-markup.org/ns/xslt/utility">
    <left-margin>200</left-margin>
    <top-margin>10</top-margin>
    <bottom-margin>10</bottom-margin>
    <background-color>white</background-color>
    <styles>
      <ranges color="white" stroke="black" opacity="0">sonnet octave sestet quatrain couplet</ranges>
      <ranges color="white" stroke="black" opacity="0" stroke-width="1">line</ranges>
      <ranges color="slategrey"  stroke="black" opacity="0.1" stroke-dasharray="2 1">s</ranges>
      <ranges color="slategrey"  stroke="black" opacity="0.2" stroke-dasharray="1 1">phr</ranges>
    </styles>
    <!--<bars indent="0">
      <ranges width="40">octave sestet quatrain couplet</ranges>
      <ranges width="20">line</ranges>
      <ranges indent="30" width="30">s</ranges>
      <ranges indent="30" width="20">phr</ranges>
    </bars>-->
    <discs indent="80">
      <range label="none">octave</range>
      <range label="none">sestet</range>
      <range label="none">quatrain</range>
      <range label="none">couplet</range>
      <range>line</range>
      <range label="left">s</range>
      <range label="left">phr</range>
    </discs>
    <title>
      <font-family>Noto Serif</font-family>
      <font-size>28</font-size>
      <line-height>40</line-height>
      <indent>440</indent>
      <drop>120</drop>
    </title>
    <text line="line">
      <font-family>Noto Serif</font-family>
      <indent>480</indent>
      <drop>200</drop>
      <font-size>16</font-size>
      <line-height>22</line-height>
      <font-color>black</font-color>
    </text>
  </xsl:variable>
  
  <xsl:template name="display-meta-info">
    <g transform="translate({ $specs/f:title/f:indent } { $specs/f:title/f:drop })">
        <xsl:for-each select="$specs/f:title/( f:font-family | f:font-size | f:fill | f:fill-opacity)">
          <xsl:attribute name="{name()}" select="string()"/>
        </xsl:for-each>
      <text x="0" y="0">
        <xsl:value-of select="$lmnl-document/x:range[@name='meta']/x:annotation[@name='title']/x:content/string(.)"/>
      </text>
      <text x="0" y="{ $specs/f:title/f:line-height }" font-size="80%">
        <xsl:value-of select="$lmnl-document/x:range[@name='meta']/x:annotation[@name='author']/x:content/string(.)"/>
      </text>
    </g>
  </xsl:template>
  
  <xsl:template name="draw-svg">
    <xsl:for-each select="$specs/f:background-color">
      <rect x="0" y="0" width="100%" height="100%"
        style="stroke:none;fill:{.}"/>
    </xsl:for-each>
    <xsl:if test="$show-source">
    <g transform="translate(20 50)" font-family="Consolas" font-size="14" fill="darkgrey">
      <xsl:for-each select="tokenize($LMNL-literal,'&#xA;')">
        <text x="0" y="{position() * 24}">
          <xsl:value-of select="."/>
        </text>
      </xsl:for-each>
    </g>
    </xsl:if>
    <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin})">
      <xsl:apply-templates select="/" mode="draw-discs"/>
      <!--<xsl:apply-templates select="/" mode="draw-bars"/>-->
    </g>
    <xsl:call-template name="display-text"/>
    <xsl:call-template name="display-meta-info"/>
    
  </xsl:template>
  
<!--  <xsl:template name="display-text">
      <xsl:variable name="text-svg">
        <xsl:apply-templates select="$specs/f:text" mode="write-text"/>
      </xsl:variable>
      <xsl:copy-of select="$text-svg"/>
  </xsl:template>-->
  
  
  <xsl:template match="/" mode="draw-discs">
    <!-- the discs diagram -->
    <g font-family="sans-serif"
      transform="translate({$specs/f:discs/@indent} 0)
      scale({$squeeze})">
      
      <xsl:for-each select="$specs/f:discs/f:range">
        <xsl:variable name="spec" select="."/>
        <xsl:variable name="style" select="$specs/f:styles/f:ranges[tokenize(.,'\s+') = current()]"/>
        <!--<xsl:variable name="fill" select="($style/@color,'black')[1]"/>
        <xsl:variable name="fill-opacity" select="($style/@opacity,'0.2')[1]"/>
        <xsl:variable name="stroke" select="($style/@stroke,$fill)[1]"/>
        <xsl:variable name="stroke-width" select="($style/@stroke-width,'1')[1]"/>
        <xsl:variable name="stroke-opacity" select="($style/@stroke-opacity,'1')[1]"/>-->
        <g style="visibility:visible">
          <!--<svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
            <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
            begin="{generate-id()}-off.click" fill="freeze"/>-->
          
          <xsl:for-each
            select="key('ranges-by-name',$spec,$lmnl-document)">
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="radius" select="((@end - @start) div 2) + 1"/>
            <circle id="bubble-{generate-id()}" class="range-bubble"
              fill="black"
              fill-opacity="0.2"
              stroke="black"
              stroke-width="1"
              stroke-opacity="1"
              cx="0" cy="{$start-y + ($radius)}" r="{$radius}">
              <xsl:apply-templates select="." mode="assign-class">
                <xsl:with-param name="class">range-bubble</xsl:with-param>
              </xsl:apply-templates>
              <xsl:apply-templates select="$style/@*" mode="copy-property"/>
            </circle>
            <xsl:call-template name="label-disc">
              <!--<xsl:with-param name="fill" select="$fill"/>
              <xsl:with-param name="fill-opacity" select="$fill-opacity"/>
              <xsl:with-param name="stroke" select="$stroke"/>
              <xsl:with-param name="stroke-width" select="$stroke-width"/>
              <xsl:with-param name="stroke-opacity" select="$stroke-opacity"/>-->
              <xsl:with-param name="spec" tunnel="yes" select="$spec"/>
              <xsl:with-param name="style" tunnel="yes" select="$style"/>
              <xsl:with-param name="radius" select="$radius"/>
              <xsl:with-param name="start-y" select="$start-y"/>
            </xsl:call-template>
            <!--             -->
          </xsl:for-each>
        </g>
      </xsl:for-each>
    </g>
  </xsl:template>
  
  <xsl:template match="f:text" mode="write-text">
    <xsl:variable name="line-range" select="$specs/f:text/@line"/>
    <!--<xsl:variable name="div-range" select="$specs/f:text/@div"/>-->
    <xsl:variable name="indent" select="($specs/f:text/f:indent,50)[1]"/>
    
    <xsl:variable name="text-styling" select="$specs/f:text/*"/>
    <!--<xsl:variable name="stroke" select="($style/@stroke,'black')[1]"/>
    <xsl:variable name="stroke-width" select="($style/@stroke-width,'1')[1]"/>
    <xsl:variable name="stroke-opacity" select="($style/@stroke-opacity,'1')[1]"/>-->
    <xsl:variable name="start-y"/>
    
    <xsl:variable name="line-ranges" select="key('ranges-by-name',$line-range,$lmnl-document)"/>
    <!--<xsl:variable name="div-ranges" select="key('ranges-by-name',$div-range,$lmnl-document)"/>-->
    <xsl:variable name="line-count" select="count($line-ranges)"/>
    <!--<xsl:variable name="vertical-center-y"  select="$line-ranges[last()]/@end div 2"/>-->
    <!--<xsl:variable name="last-y" select="$line-ranges[last()]/@end"/>-->
    
    <g fill="black" font-size="24" font-family="sans-serif"
      transform="translate({ $text-styling/self::f:indent } { $text-styling/self::f:drop })">
      <xsl:apply-templates select="$text-styling" mode="copy-property"/>
      
      <xsl:for-each select="$line-ranges">
        <xsl:variable name="which" select="position()"/>
        <!-- start-y and radius measure the extent of the range -->
        <!--<xsl:variable name="start-y" select="@start"/>-->
        <xsl:variable name="radius" select="(@end - @start) div 2"/>
        
        <!-- line-count, last-y and y space the lines evenly, leaving a
           single line height for the divs -->
        <xsl:variable name="y" select="$which * ($text-styling/self::f:line-height/number(),28)[1]"/>
        <!-- first drawing a line from the vertical position of this range to the
           text baseline -->
        <!--<path fill="none"  stroke="{$stroke}"
          stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
          d="M 0 {$start-y + $radius} L {$indent - 5} {$y}"/>-->
        <line x1="0" y1="{$y - 8}" x2="1024" y2="{$y}" stroke="gainsboro" stroke-width="16" stroke-opacity="0.4"/>
        <text x="0" y="{$y}" >
          <xsl:apply-templates select="key('spans-by-range',@ID)" mode="write"/>
        </text>
      </xsl:for-each>    
      
    </g>
  </xsl:template>
  
  <xsl:template match="f:font-color" mode="copy-property">
    <xsl:attribute name="fill" select="."/>
  </xsl:template>
  
  <xsl:template match="@indent | @drop" mode="copy-property"/>
    
  <xsl:template match="*" mode="copy-property">
    <xsl:attribute name="{local-name()}" select="."/>
  </xsl:template>
  
  <!-- EOL of LF, CR, or CRLF are all normalized to LF (&#xA;) -->
  <xsl:function name="f:eol" as="xs:string?">
    <xsl:param name="in" as="xs:string?"/>
    <xsl:sequence select="replace($in,'&#xA;|(&#xD;&#xA;?)','&#xA;')"/>
  </xsl:function>
</xsl:stylesheet>