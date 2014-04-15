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
      <ranges color="lavender" opacity="0.2" width="10">preface introduction chapter div verse-para</ranges>
      <ranges color="skyblue" width="10">lg verse</ranges>
      <ranges color="steelblue" width="10">l line</ranges>
      <ranges color="orange" width="10">s seg</ranges>
      <ranges color="pink" width="10">letter entry</ranges>
      <ranges color="lightgreen" opacity="0.3" line="gold" line-weight="10"
        line-opacity="0.8" width="10">story q</ranges>
    </styles>
    <bars indent="20">
      <ranges width="10">story</ranges>
      <ranges width="10">chapter</ranges>
      <ranges width="10">q</ranges>
    </bars>
    <discs indent="400">
      <range>preface</range>
      <range>introduction</range>
      <range label="left">story</range>
      <range label="left">letter</range>
      <range label="left">entry</range>
      <range>chapter</range>
      <range label="left">q</range>
    </discs>
    <text line="l">
      <font-size>36</font-size>
      <highlight color="green">q</highlight>
    </text>
    <!--<buttons>
      <indent>160</indent>
      <drop>15</drop>
    </buttons>-->
  </xsl:variable>
  
  
  <xsl:variable name="lmnl-document" select="/x:document"/>
  
  <xsl:key name="ranges-by-name" match="x:document/x:range" use="@name"/>
  
  <xsl:key name="ranges-by-ID" match="x:document/x:range" use="@ID"/>
  
  <xsl:key name="spans-by-range" match="x:span" use="tokenize(@ranges,'\s+')"/>
  
  <xsl:variable name="doc-length" select="(/x:document/x:content/x:span[last()]/@end,0)[1]"/>
  
  <xsl:variable name="squeeze"
    select="f:round(600 - ($specs/f:top-margin + $specs/f:bottom-margin)) div $doc-length"/>
  
  <xsl:template match="/">
    <svg width="800" height="600" viewPort="0 0 800 600">
      <xsl:call-template name="draw-svg"/>
    </svg>
  </xsl:template>
  
  <xsl:template name="draw-svg">
    <xsl:for-each select="$specs/f:background-color">
      <rect x="0" y="0" width="100%" height="100%"
        style="stroke:none;fill:{.}"/>
    </xsl:for-each>
    <g transform="translate({$specs/f:left-margin} {$specs/f:top-margin})">
      <xsl:apply-templates select="/" mode="draw-discs"/>
      <xsl:apply-templates select="/" mode="draw-bars"/>
    </g>
  </xsl:template>

  
  <xsl:template match="/" mode="draw-discs">
    <!-- the discs diagram -->
    <g font-family="sans-serif"
      transform="translate({$specs/f:discs/@indent} 0)
      scale({$squeeze})">
      
      <xsl:for-each select="$specs/f:discs/f:range">
        <xsl:variable name="spec" select="."/>
        
        <xsl:variable name="style" select="$specs/f:styles/f:ranges[tokenize(.,'\s+') = current()]"/>
        <xsl:variable name="fill" select="($style/@color,'black')[1]"/>
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
            select="key('ranges-by-name',$spec,$lmnl-document)">
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="radius" select="(@end - @start) div 2"/>
            <circle id="bubble-{generate-id()}" class="range-bubble" fill="{$fill}" fill-opacity="{$fill-opacity}" stroke="{$stroke}"
              stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
              cx="0" cy="{$start-y + ($radius)}" r="{$radius}">
              <xsl:apply-templates select="." mode="assign-class">
                <xsl:with-param name="class">range-bubble</xsl:with-param>
              </xsl:apply-templates>
            </circle>
            <xsl:call-template name="label-disc">
              <xsl:with-param name="fill" select="$fill"/>
              <xsl:with-param name="fill-opacity" select="$fill-opacity"/>
              <xsl:with-param name="stroke" select="$stroke"/>
              <xsl:with-param name="stroke-width" select="$stroke-width"/>
              <xsl:with-param name="stroke-opacity" select="$stroke-opacity"/>
              <xsl:with-param name="spec" select="$spec"/>
              <xsl:with-param name="radius" select="$radius"/>
              <xsl:with-param name="start-y" select="$start-y"/>
            </xsl:call-template>
            <!--             -->
          </xsl:for-each>
        </g>
      </xsl:for-each>
      
      <xsl:call-template name="display-text"/>
      
    </g>
  </xsl:template>
  
  <xsl:template name="label-disc">
    <xsl:param name="fill"/>
    <xsl:param name="fill-opacity"/>
    <xsl:param name="stroke"/>
    <xsl:param name="stroke-width"/>
    <xsl:param name="stroke-opacity"/>
    <xsl:param name="spec"/>
    <xsl:param name="radius"/>
    <xsl:param name="start-y"/>
    <xsl:if test="not($spec/@label='none')">
      <text fill="{$fill}" fill-opacity="{$fill-opacity}" stroke="{$stroke}"
        stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
        x="{if ($spec/@label='left') then '-' else ''}{$radius div 4}" y="{$start-y + ($radius)}"
        font-size="{$radius}">
        <xsl:attribute name="text-anchor" select="if ($spec/@label='left') then 'end' else 'start'"/>
        <xsl:apply-templates select="." mode="label-disc"/>
      </text>
    </xsl:if>
  </xsl:template>
  
  <!-- override in a calling stylesheet to modify the label -->
  <xsl:template match="*" mode="label-disc">
    <xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template match="*" mode="assign-class"/>
  
  <xsl:template name="display-text">
    <g id="text">
    <xsl:apply-templates select="$specs/f:text" mode="write-text"/>
    </g>
  </xsl:template>
  
  <xsl:template match="f:text" mode="write-text">
    <xsl:variable name="line-range" select="$specs/f:text/@line"/>
    <!--<xsl:variable name="div-range" select="$specs/f:text/@div"/>-->
   <xsl:variable name="indent" select="($specs/f:text/@indent,50)[1]"/>
    
    <xsl:variable name="range-spec" select="$specs/f:styles/f:ranges[tokenize(.,'\s+')=$line-range]"/>
    <xsl:variable name="stroke" select="($range-spec/@stroke,'black')[1]"/>
    <xsl:variable name="stroke-width" select="($range-spec/@stroke-width,'1')[1]"/>
    <xsl:variable name="stroke-opacity" select="($range-spec/@stroke-opacity,'1')[1]"/>
    <xsl:variable name="start-y"/>
    
    <xsl:variable name="line-ranges" select="key('ranges-by-name',$line-range,$lmnl-document)"/>
    <!--<xsl:variable name="div-ranges" select="key('ranges-by-name',$div-range,$lmnl-document)"/>-->
    <xsl:variable name="line-count" select="count($line-ranges)"/>
    <xsl:variable name="last-y" select="$line-ranges[last()]/@end"/>
    
    <g fill="{($specs/f:text/f:font-color,'black')[1]}"
      font-size="{($specs/f:text/f:font-size,'24')[1]}"
      font-family="{($specs/f:text/f:font-family,'sans-serif')[1]}">

      <xsl:for-each select="$line-ranges">
        <!-- start-y and radius measure the extent of the range -->
        <xsl:variable name="start-y" select="@start"/>
        <xsl:variable name="radius" select="(@end - @start) div 2"/>
        
        <!-- line-count, last-y and y space the lines evenly, leaving a
           single line height for the divs -->
        <xsl:variable name="y" select="(position() - 0.5) * ($last-y div $line-count)"/>
        <!-- first drawing a line from the vertical position of this range to the
           text baseline -->
        <path fill="none"  stroke="{$stroke}"
          stroke-width="{$stroke-width}" stroke-opacity="{$stroke-opacity}"
          d="M 0 {$start-y + $radius} L {$indent - 5} {$y}"/>
        <text x="{$indent}" y="{$y}" >
          <xsl:apply-templates select="key('spans-by-range',@ID)" mode="write"/>
        </text>
      </xsl:for-each>    
      
    </g>
  </xsl:template>
  
  <!--<xsl:template priority="2"
    match="x:span[f:starting-ranges(.)/@name = $specs/f:text/@div]" mode="write">
    <xsl:variable name="line-ranges" select="key('ranges-by-name',$specs/f:text/@line,$lmnl-document)"/>
    <xsl:variable name="div-ranges" select="key('ranges-by-name',$specs/f:text/@div,$lmnl-document)"/>
    <xsl:variable name="line-count" select="count($line-ranges | $div-ranges)"/>
    <xsl:variable name="last-y" select="$line-ranges[last()]/@end"/>
    <svg:tspan dx="0" dy="{($last-y div $line-count)}">&#xA0;</svg:tspan>
    <xsl:next-match/>
  </xsl:template>-->
    
  <xsl:template match="x:span" mode="write">
    <xsl:apply-templates select="." mode="format"/>
  </xsl:template>
  
  <xsl:template
    match="x:span[f:ranges(.)/@name
    = $specs/f:text/f:highlight/@ranges/tokenize(.,'\s+')]" mode="write">
    <!-- $in-ranges collects the range in which this span appears -->
    <xsl:variable name="in-ranges"
      select="f:ranges(.)[@name = $specs/f:text/f:highlight/@ranges/tokenize(.,'\s+')]"/>
    
    <!-- picking the highlight color of the innermost highlighted range -->
    <xsl:variable name="color" select="$specs/f:text/f:highlight[@ranges/tokenize(.,'\s+') =
      $in-ranges[(@end - @start) eq min($in-ranges/(@end - @start))]/@name][1]"/>
    <tspan fill="{($color,'green')[1]}">
      <xsl:next-match/>
    </tspan>
  </xsl:template>
  
  <xsl:template match="/" mode="draw-bars">
    <!-- the plots diagram -->
    <g transform="translate({($specs/f:bars/@indent,0)[1]} 0)
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
            select="key('ranges-by-name',tokenize(current(),' '),$lmnl-document)">
            <xsl:variable name="spec" select="."/>
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
            <rect id="{replace(@ID,'^R.','bar-')}" class="range-bar" title="{@name}"
              x="{$indent}" y="{$start-y}"
              rx="4" ry="4"
              width="{$width}" height="{$height}" stroke="{$stroke}"
              fill="{$fill}" fill-opacity="{$fill-opacity}" stroke-width="{$stroke-width}">
              <!-- class assignment is dynamic to enable customized animation hooks -->
              <xsl:apply-templates select="." mode="assign-class">
                <xsl:with-param name="range-bar"/>
              </xsl:apply-templates>
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
  
  <xsl:function name="f:ranges" as="element(x:range)*">
    <!-- returns the set of ranges covering a given span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/key('ranges-by-ID',tokenize(@ranges,'\s+'),$lmnl-document)"/>
  </xsl:function>
  
  <xsl:function name="f:starting-ranges" as="element(x:range)*">
    <!-- returns any ranges starting with this span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/f:ranges(.)
      except $span/preceding-sibling::x:span[1]/f:ranges(.)"/>
  </xsl:function>
  
  <xsl:function name="f:ending-ranges" as="element(x:range)*">
    <!-- returns any ranges starting with this span -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:sequence select="$span/f:ranges(.)
      except $span/following-sibling::x:span[1]/f:ranges(.)"/>
  </xsl:function>
  
</xsl:stylesheet>