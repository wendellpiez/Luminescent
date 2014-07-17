<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">
  
  <!--xmlns:svg="http://www.w3.org/2000/svg"-->
  
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
    <bars indent="20">
      <ranges width="80">act</ranges>
      <ranges width="100" indent="40">scene</ranges>
      <ranges width="100" indent="80">sp</ranges>
    </bars>
    <discs indent="320">
      <range label="left">act</range>
      <range label="right">scene</range>
      <range label="left">sp</range>
    </discs>
  </xsl:variable>
  
  
  <!-- A structured xLMNL instance representing a discrete
       layer (i.e., document or annotation) -->
  <xsl:param name="structured-lmnl" select="/x:document"/>
  
  <!-- The component being displayed -->
  <xsl:param name="display-fragment" select="$structured-lmnl"/>
  
  <xsl:key name="ranges-by-rID" match="x:div | x:start | x:empty" use="@rID"/>

  <xsl:function name="f:return-ranges-for-fragment" as="element()*">
    <!-- returns a set of x:div, x:start or x:empty elements
         representing ranges with @name=$n, appearining within a fragment
         (document, div or annotation); note this includes ranges that
         overlap the fragment as well as those enclosed -->
    <xsl:param name="n" as="xs:string"/>
    <xsl:param name="fragment" as="element()"/>
    <xsl:variable name="spans" select="$fragment//x:span except $fragment//x:annotation//x:span"/>
    <xsl:sequence select="$spans/f:return-ranges-for-span(.)[@name=$n]"/>
    
  </xsl:function>
  
  <xsl:function name="f:return-ranges-for-span" as="element()*">
    <!-- returns the set of ranges covering a given span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/key('ranges-by-rID',tokenize(@ranges,'\s+'),$structured-lmnl)"/>
  </xsl:function>
  
  <xsl:function name="f:starting-ranges" as="element()*">
    <!-- returns any ranges starting with this span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/f:return-ranges-for-span(.)
      except $span/preceding-sibling::x:span[1]/f:return-ranges-for-span(.)"/>
  </xsl:function>
  
  <xsl:function name="f:ending-ranges" as="element()*">
    <!-- returns any ranges ending with this span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/f:return-ranges-for-span(.)
      except $span/following-sibling::x:span[1]/f:return-ranges-for-span(.)"/>
  </xsl:function>
  
  
  <!--<xsl:key name="spans-by-range" match="x:span" use="tokenize(@ranges,'\s+')"/>-->
  
  <xsl:variable name="display-length" select="$display-fragment/@end - $display-fragment/@start"/>
  
  <xsl:variable name="squeeze"
    select="if ($display-length le 600) then 1 else
    f:round((600 - ($specs/f:top-margin + $specs/f:bottom-margin)) div $display-length)"/>
  
  <xsl:template match="/">
    <svg width="800" height="600" viewPort="0 {$structured-lmnl/@start} 800 600">
      <xsl:call-template name="draw-svg"/>
    </svg>
  </xsl:template>
  
  <xsl:template name="draw-svg">
    <xsl:for-each select="$specs/f:background-color">
      <rect x="0" y="0" width="100%" height="100%"
        style="stroke:none;fill:{.}"/>
    </xsl:for-each>
    <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin}))">
      <xsl:apply-templates select="$display-fragment" mode="draw-discs"/>
      <xsl:apply-templates select="$display-fragment" mode="draw-bars"/>
    </g>
  </xsl:template>

  
  <xsl:template match="/ | x:document | x:annotation | x:div" mode="draw-discs">
    <!-- the discs diagram -->
    <g font-family="sans-serif"
      transform="translate({$specs/f:discs/@indent} {0 - ($display-fragment/@start * $squeeze)})
      scale({$squeeze})">
      
      <xsl:for-each select="$specs/f:discs/f:range">
        <xsl:variable name="spec" select="."/>
        <xsl:variable name="style" select="$specs/f:styles/f:ranges[tokenize(.,'\s+') = $spec]"/>
        <xsl:variable name="fill" select="($style/@color,'white')[1]"/>
        <xsl:variable name="fill-opacity" select="($style/@opacity,'0.2')[1]"/>
        <xsl:variable name="stroke" select="($style/@stroke,$fill)[1]"/>
        <xsl:variable name="stroke-width" select="($style/@stroke-width,'1')[1]"/>
        <xsl:variable name="stroke-opacity" select="($style/@stroke-opacity,'1')[1]"/>
        <g style="visibility:visible">
          <!--<svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
            <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
            begin="{generate-id()}-off.click" fill="freeze"/>-->
          
          <xsl:for-each
            select="f:return-ranges-for-fragment(string($spec),$display-fragment)">
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="radius" select="(@end - @start) div 2"/>
            <circle id="{replace(@rID,'^R.','bubble-')}" class="range-bubble"
              fill="{$fill}" fill-opacity="{$fill-opacity}" stroke="{$stroke}"
              stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
              cx="0" cy="{$start-y + ($radius)}" r="{$radius}">
              <xsl:apply-templates select="." mode="assign-class">
                <xsl:with-param name="class">range-bubble</xsl:with-param>
              </xsl:apply-templates>
              <!--<xsl:apply-templates select="." mode="animate-bubble">
                <xsl:with-param name="stroke-width" select="number($stroke-width)"/>
                <xsl:with-param name="fill-opacity" select="number($fill-opacity)"/>
              </xsl:apply-templates>-->
            </circle>
            <text fill="{$fill}" fill-opacity="{$fill-opacity}"
              stroke="{$stroke}" stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
              x="{if ($spec/@label='left') then '-' else ''}{$radius div 4}"
              y="{$start-y + ($radius)}" font-size="{$radius}">
              <xsl:if test="not($spec/@label='none')">
                <xsl:attribute name="text-anchor"
                  select="if ($spec/@label='left') then 'end' else 'start'"/>
                <xsl:value-of select="@name"/>
              </xsl:if>
            </text>
            <!--             -->
            <!--<xsl:apply-templates select="." mode="decorate-bubble">
              <xsl:with-param name="y" select="$start-y + $radius"/>
              <xsl:with-param name="style" select="$style"/>
            </xsl:apply-templates>-->
          </xsl:for-each>
        </g>
      </xsl:for-each>
      
    </g>
  </xsl:template>
  
  <xsl:template match="*" mode="decorate-bubble"/>
  
  <xsl:template match="*" mode="assign-class"/>
  
  <xsl:template match="*" mode="animate"/>
  
  <xsl:template match="/ | x:document | x:annotation | x:div" mode="draw-bars">
    <!-- the plots diagram -->
    <g transform="translate({($specs/f:bars/@indent,0)[1]}  {0 - ($display-fragment/@start * $squeeze)})
      scale(1 {$squeeze})">
      
      <xsl:for-each select="$specs/f:bars/f:ranges">
        <!-- for indenting the bars -->
        <xsl:variable name="range-set" select="position() - 1"/>
        <xsl:variable name="width" select="@width"/>
        <xsl:variable name="indent" select="(@indent,0)[1]"/>
        <g style="visibility:visible">
          <!--<svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
          <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
            begin="{generate-id()}-off.click" fill="freeze"/>-->
          <xsl:for-each
            select="f:return-ranges-for-fragment(tokenize(.,'\s+'),$display-fragment)">
            <xsl:variable name="style" select="$specs/f:styles/f:ranges[tokenize(.,'\s+') = current()/@name]"/>
            <xsl:variable name="fill" select="($style/@color,'white')[1]"/>
            <xsl:variable name="fill-opacity" select="($style/@opacity,'0.2')[1]"/>
            <xsl:variable name="stroke" select="($style/@stroke,$fill)[1]"/>
            <xsl:variable name="stroke-width" select="($style/@stroke-width,'1')[1]"/>
            <xsl:variable name="stroke-opacity" select="($style/@stroke-opacity,'1')[1]"/>
            
            <!--<xsl:variable name="style"
              select="$specs/f:styles/f:ranges[tokenize(.,'\s+') = current()/@name]"/>
            
            <xsl:variable name="color" select="$style/@color"/>
            <xsl:variable name="width" select="$width"/>-->
            
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="height" select="@end - @start"/>
            <rect id="{replace(@rID,'^R.','bar-')}" class="range-bar" title="{@name}"
              x="{$indent}" y="{$start-y}"
              rx="4" ry="4"
              width="{$width}" height="{$height}" stroke="{$stroke}"
              fill="{$fill}" fill-opacity="{$fill-opacity}" stroke-width="{$stroke-width}">
              <!--<xsl:apply-templates select="." mode="animate">
                <xsl:with-param name="stroke-width" select="1"/>
                <xsl:with-param name="fill-opacity" select="0.2"/>
              </xsl:apply-templates>-->
            </rect> 
          </xsl:for-each>
        </g>
      </xsl:for-each>
    </g>
  </xsl:template>
  
  
  
  <xsl:function name="f:round">
    <xsl:param name="n"/>
    <xsl:value-of select="format-number($n,'0.000')"/>
  </xsl:function>
  
  
</xsl:stylesheet>