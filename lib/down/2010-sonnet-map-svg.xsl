<?xml version="1.0" standalone="no"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY ldquo '&#x201C;' >
<!ENTITY rdquo '&#x201D;' >
]>

<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl.org/namespace/LMNL/xLMNL"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:u="http://www.lmnl.org/xslt/utility"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="svg xs x u">
  <!-- Takes Reified LMNL input and graphs ranges of designated types
     as bars -->

<xsl:variable name="specs">
  <background-color>cornsilk</background-color>
  <title>
    <font-family>sans-serif</font-family>
    <font-size>18</font-size>
    <line-height>30</line-height>
    <indent>220</indent>
    <drop>30</drop>
  </title>
  <bars>
    <indent>20</indent>
    <drop>150</drop>
    <y-squeeze>0.6</y-squeeze>
  </bars>
  <discs>
    <indent>600</indent>
    <x-squeeze>0.6</x-squeeze>
  </discs>
  <!--<arcs>
    <indent>250</indent>
    <drop>580</drop>
    <x-squeeze>0.8</x-squeeze>
    <y-squeeze>0.5</y-squeeze>
  </arcs>-->
  <text>
    <font-size>18</font-size>
    <!--<line-height>28</line-height>-->
    <line-height-factor>0.63</line-height-factor>
    <indent>120</indent>
    <drop>140</drop>
  </text>
  <buttons>
    <indent>160</indent>
    <drop>15</drop>
  </buttons>
</xsl:variable>
 
<xsl:variable name="lmnl-document" select="/*/x:document"/>
  
<xsl:variable name="draw-ranges">
  <!-- ranges can be grouped in sets, but ranges in a set should
       be discrete (no overlap or enclosure please) or results
       will be confusing -->
  <!--<ranges color="gold" arc="gold">sonnet</ranges>-->
  <ranges color="peru">octave sestet</ranges>
  <ranges color="indianred">quatrain tercet couplet</ranges>
  <ranges color="darkred">line</ranges>
  <ranges color="midnightblue">phr</ranges>
  <ranges color="steelblue">s</ranges>
  <!--<ranges color="grey">octave sestet</ranges>
  <ranges color="grey">quatrain tercet couplet</ranges>
  <ranges color="grey">line</ranges>
  <ranges color="grey">s</ranges>
  <ranges color="grey">phr</ranges>-->
</xsl:variable>

  <xsl:key name="ranges-by-name" match="x:range" use="@name"/>
  
  <xsl:key name="ranges-by-id" match="x:range" use="@ID"/>
  
  <!--<xsl:variable name="longest"
    select="max(for $r in ($draw-ranges/ranges/tokenize(.,' '))
                return key('ranges-by-name',$r,$lmnl-document)/(@end - @start))"/>-->

  <xsl:variable name="flat-sonnet">
    <xsl:apply-templates select="/" mode="segment"/>
  </xsl:variable>

  <xsl:key name="spans-by-range" match="span" use="tokenize(@ranges,' ')"/>
  
  <xsl:template match="/">
    <!--<xsl:copy-of select="$flat-sonnet"/>-->
    <svg:svg width="1024" height="768" 
      onload="InitSMIL(evt)" viewBox="0 0 800 600">
      
      <svg:script type='text/ecmascript' xlink:href='smilScript.js' />
      
      <svg:rect x="0" y="0" width="100%" height="100%"
        style="stroke:black;fill:{$specs/background-color}"/>

      <xsl:apply-templates select="$flat-sonnet" mode="write-title"/>

      <!--<xsl:apply-templates select="." mode="draw-arcs"/>-->
      
      <xsl:apply-templates select="." mode="draw-discs"/>
      
      <xsl:apply-templates select="." mode="draw-bars"/>
      
      <xsl:apply-templates select="$flat-sonnet" mode="write-sonnet"/>
      
      
      <xsl:apply-templates select="." mode="draw-buttons"/>
      
    </svg:svg>

  </xsl:template>
  
  <xsl:template match="/" mode="draw-buttons">
    <svg:g transform="translate({$specs/buttons/indent} {$specs/buttons/drop})">
      <xsl:for-each select="$draw-ranges/ranges">
        <xsl:variable name="key-drop" select="24 * (position() - 1)"/>
        <svg:rect fill="white" stroke="{@color}" stroke-width="2" rx="8" ry="6"
          width="20" height="16" x="0" y="{$key-drop}" id="{generate-id()}-on"/>
        <svg:rect fill="{@color}" fill-opacity="0.6" rx="8" ry="6" width="20"
          height="16" x="0" y="{$key-drop}" id="{generate-id()}-off"
          style="visibility:visible">
          <svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
          <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
            begin="{generate-id()}-off.click" fill="freeze"/>
        </svg:rect>
        <svg:g transform="translate(-10 {$key-drop})" text-anchor="end">
          <svg:text font-size="12" y="12"
            font-style="italic" font-family="{$specs/title/font-family}">
            <xsl:for-each select="tokenize(.,'\s')">
              <xsl:value-of select="."/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </svg:text>
        </svg:g>
      </xsl:for-each>
    </svg:g>
  </xsl:template>
  
  
  <xsl:template match="/" mode="draw-arcs">
    <!-- then, the arcs diagram -->
    <svg:g
      transform="translate({$specs/arcs/indent} {$specs/arcs/drop})
      scale({$specs/arcs/x-squeeze} {$specs/arcs/y-squeeze})">
      
      <xsl:for-each select="$draw-ranges/ranges">
        <xsl:variable name="color" select="@color"/>
        <svg:g style="visibility:visible">
          <svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
          <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
          begin="{generate-id()}-off.click" fill="freeze"/>
          <xsl:for-each
            select="key('ranges-by-name',tokenize(current(),' '),$lmnl-document)">
            <xsl:variable name="start-x" select="@start"/>
            <xsl:variable name="end-x" select="@end"/>
            <xsl:variable name="length" select="@end - @start"/>
            <xsl:variable name="height" select="0 - $length"/>
            <svg:path fill="{$color}" stroke="white" fill-opacity="0.2"
              stroke-width="5" stroke-opacity="0.5"
              d="M {$start-x} 0 C {$start-x} {$height} {$end-x} {$height} {$end-x} 0">
              <svg:set attributeName="stroke" attributeType="XML" to="{$color}"
                begin="{generate-id()}-bar.mouseover" fill="freeze"/>
              <svg:set attributeName="stroke" attributeType="XML" to="white"
                begin="{generate-id()}-bar.mouseout" fill="freeze"/>
              <xsl:for-each select="key('spans-by-range',@ID,$flat-sonnet)">
                <!--<svg:set attributeName="fill-opacity" attributeType="XML"
                  to="0.3" begin="{generate-id()}-span.mouseover" fill="freeze"/>
                <svg:set attributeName="fill-opacity" attributeType="XML"
                  to="0.1" begin="{generate-id()}-span.mouseout" fill="freeze"/>-->
                <svg:set attributeName="stroke" attributeType="XML"
                  to="{$color}" begin="{generate-id()}-span.mouseover"
                  fill="freeze"/>
                <svg:set attributeName="stroke" attributeType="XML" to="white"
                  begin="{generate-id()}-span.mouseout" fill="freeze"/>
              </xsl:for-each>
            </svg:path>
          </xsl:for-each>
        </svg:g>
      </xsl:for-each>
    </svg:g>
    </xsl:template>
  
  <xsl:template match="/" mode="draw-discs">
    <!-- then, the discs diagram -->
    <svg:g
      transform="translate({$specs/discs/indent} {$specs/bars/drop})
      scale({$specs/discs/x-squeeze} {$specs/bars/y-squeeze})">
      
      
      <xsl:for-each select="$draw-ranges/ranges">
        <xsl:variable name="color" select="@color"/>
        <svg:g style="visibility:visible">
          <svg:set attributeName="visibility" attributeType="CSS" to="visible"
            begin="{generate-id()}-on.click" fill="freeze"/>
          <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
            begin="{generate-id()}-off.click" fill="freeze"/>
          <xsl:for-each
            select="key('ranges-by-name',tokenize(current(),' '),$lmnl-document)">
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="radius" select="(@end - @start) div 2"/>
            <svg:circle fill="{$color}" stroke="white" fill-opacity="0.2"
              stroke-width="3" stroke-opacity="0.5"
              cx="0" cy="{$start-y + ($radius)}" r="{$radius}">
              <svg:set attributeName="fill-opacity" attributeType="XML" to="0.4"
                begin="{generate-id()}-bar.mouseover" fill="freeze"/>
              <svg:set attributeName="fill-opacity" attributeType="XML" to="0.2"
                begin="{generate-id()}-bar.mouseout" fill="freeze"/>
              <xsl:for-each select="key('spans-by-range',@ID,$flat-sonnet)">
                <!--<svg:set attributeName="fill-opacity" attributeType="XML"
                  to="0.3" begin="{generate-id()}-span.mouseover" fill="freeze"/>
                  <svg:set attributeName="fill-opacity" attributeType="XML"
                  to="0.1" begin="{generate-id()}-span.mouseout" fill="freeze"/>-->
                <svg:set attributeName="stroke" attributeType="XML"
                  to="{$color}" begin="{generate-id()}-span.mouseover"
                  fill="freeze"/>
                <svg:set attributeName="stroke" attributeType="XML" to="white"
                  begin="{generate-id()}-span.mouseout" fill="freeze"/>
              </xsl:for-each>
            </svg:circle>
          </xsl:for-each>
        </svg:g>
      </xsl:for-each>
    </svg:g>
  </xsl:template>
  
  <xsl:template match="/" mode="draw-bars">
    <!-- the plots diagram -->
    <svg:g
      transform="translate({$specs/bars/indent} {$specs/bars/drop})
      scale({($specs/bars/x-squeeze,1)[1]} {$specs/bars/y-squeeze})">
      
      <xsl:for-each select="$draw-ranges/ranges">
        <!-- for indenting the bars -->
        <xsl:variable name="range-set" select="position() - 1"/>
        <xsl:variable name="color" select="@color"/>
       <svg:g style="visibility:visible">
         <svg:set attributeName="visibility" attributeType="CSS" to="visible"
           begin="{generate-id()}-on.click" fill="freeze"/>
         <svg:set attributeName="visibility" attributeType="CSS" to="hidden"
           begin="{generate-id()}-off.click" fill="freeze"/>
         <xsl:for-each
            select="key('ranges-by-name',tokenize(current(),' '),$lmnl-document)">
            <xsl:variable name="start-y" select="@start"/>
            <xsl:variable name="height" select="@end - @start"/>
            <svg:rect id="{generate-id()}-bar"
               x="{$range-set * 16}" y="{$start-y}"
               rx="4" ry="4"
               width="15" height="{$height}" stroke="white"
               fill="{$color}" fill-opacity="0.5" stroke-width="2">
              <svg:set attributeName="fill-opacity" attributeType="XML" to="1"
                begin="mouseover" fill="freeze"/>
              <svg:set attributeName="fill-opacity" attributeType="XML" to="0.5"
                begin="mouseout" fill="freeze"/>
              <xsl:for-each select="key('spans-by-range',@ID,$flat-sonnet)">
                <svg:set attributeName="fill-opacity" attributeType="XML" to="1"
                  begin="{generate-id()}-span.mouseover" fill="freeze"/>
                <svg:set attributeName="fill-opacity" attributeType="XML" to="0.5"
                  begin="{generate-id()}-span.mouseout" fill="freeze"/>
              </xsl:for-each>
            </svg:rect> 
          </xsl:for-each>
        </svg:g>
      </xsl:for-each>
    </svg:g>
  </xsl:template>
  
  <!--  <xsl:function name="u:round">
    <xsl:param name="n"/>
    <xsl:value-of select="format-number($n,'0.000')"/>
  </xsl:function>
-->  
  
  <xsl:variable name="stacked"
    select="('sonnet','octave','sestet','quatrain','tercet','couplet','line','s','phr')"/>
  
  <xsl:variable name="xLMNL-ranges" as="element(x:range)*"
    select="$lmnl-document/x:range[@name=$stacked]"/>
  
  <xsl:variable name="range-starts" select="$xLMNL-ranges/@start/number()"/>
  
  <xsl:variable name="range-ends" select="$xLMNL-ranges/@end/number()"/>
  
  <xsl:variable name="boundaries" as="xs:double*">
    <xsl:perform-sort select="distinct-values((0,$range-starts, $range-ends))">
      <xsl:sort data-type="number"/>
    </xsl:perform-sort>
  </xsl:variable>
  
  
  
  <xsl:template match="x:document" mode="segment">
    <!-- this template is a reduced variant of the 'stacker' routine
         (see xLMNL-stacker.xsl), producing a segmented version
         of the sonnet wherein text fragments are marked with the
         ranges in which they participate -->
    <xsl:variable name="text" select="x:content"/>
    <sonnet>
      <xsl:for-each select="x:range[@name='meta']">
        <meta>
          <author>
            <xsl:value-of select="x:annotation[@name='author']/x:content"/>
          </author>
          <title>
            <xsl:value-of select="x:annotation[@name='title']/x:content"/>
          </title>
        </meta>
      </xsl:for-each>      
      <xsl:for-each select="$boundaries[position() lt last()]">
        <xsl:variable name="p" select="position()"/>
        <xsl:variable name="s" select="xs:integer(.)"/>
        <xsl:variable name="e" select="xs:integer($boundaries[$p + 1])"/>
        <xsl:variable name="ranges-here" as="element(x:range)*">
          <xsl:perform-sort select="$xLMNL-ranges[u:covering(.,$s,$e)]">
            <!-- <xsl:perform-sort select="key('covering-ranges',concat($s,'-',$e)]">
                it may be possible to speed up processing by indexing $ranges
                by covering positions, using a key -->
            <xsl:sort select="@end - @start" order="descending"/>
            <xsl:sort select="index-of($stacked,@name)"/>
          </xsl:perform-sort>
        </xsl:variable>
        <span
          ranges="{string-join(($ranges-here/@ID),' ')}">
          <xsl:value-of select="substring($text,($s + 1),($e - $s))"/>
        </span>
      </xsl:for-each>
    </sonnet>
  </xsl:template>
  
  <xsl:function name="u:covering" as="xs:boolean">
    <!-- useful if we do this more than once w/ given arguments
      xmlns:saxon="http://saxon.sf.net/ saxon:memo-function="yes" -->
    <xsl:param name="range" as="element(x:range)"/>
    <xsl:param name="start" as="xs:integer"/>
    <xsl:param name="end" as="xs:integer"/>
    <xsl:sequence select="$start ge xs:integer($range/@start) and $end le xs:integer($range/@end)"/>
  </xsl:function>
  
  <xsl:variable name="line-height"
    select="$specs/text/line-height-factor * 
            avg(
     (key('ranges-by-name','line',$lmnl-document))/(@end - @start))"/>
  
  <xsl:template match="sonnet" mode="write-sonnet">
    <!-- takes segmented sonnet input and displays it -->
    <svg:g transform="translate({$specs/text/indent} {$specs/text/drop})"
      font-size="{$specs/text/font-size}" font-weight="bold"
      font-family="serif">
    <xsl:for-each-group select="span[contains(@ranges,'line')]"
      group-adjacent="tokenize(@ranges,'\s')[contains(.,'line')]">
      <!--<xsl:variable name="drop"
        select="((position() - 1) * $specs/text/line-height)"/>-->
      <!-- drop proportional to average line length! -->
      <xsl:variable name="drop"
        select="format-number(
          (position() * ($line-height)),'#.##')"/>
      <svg:text x="0" y="{$drop}">
        <!--<xsl:value-of select="$avg-line-length"/>
        <xsl:text> </xsl:text>-->
        <xsl:apply-templates select="current-group()" mode="write-sonnet"/>
      </svg:text>
    </xsl:for-each-group>
    </svg:g>
  </xsl:template>
  
  <xsl:template match="span" mode="write-sonnet">
    <svg:tspan fill="grey" id="{generate-id()}-span">
       <xsl:for-each select="for $r in tokenize(@ranges,' ')
        return key('ranges-by-id',$r,$lmnl-document)">
        <svg:set attributeName="fill" attributeType="XML" to="black"
          begin="{generate-id()}-bar.mouseover" fill="freeze"/>
        <svg:set attributeName="fill" attributeType="XML" to="grey"
          begin="{generate-id()}-bar.mouseout" fill="freeze"/>
      </xsl:for-each>
      
      <xsl:apply-templates/>
    </svg:tspan>
  </xsl:template>
  
  <xsl:template match="sonnet" mode="write-title">
    <svg:g transform="translate({$specs/title/indent} {$specs/title/drop})">
      <xsl:apply-templates select="meta" mode="write-title"/>
    </svg:g>
  </xsl:template>
  
  <xsl:template match="meta" mode="write-title">
    <svg:g font-family="{($specs/title/font-family,'serif')[1]}"
        font-size="{($specs/title/font-size,'serif')[1]}">
      <xsl:apply-templates select="author,title" mode="write-title"/>
    </svg:g>
  </xsl:template>
  
  <xsl:template match="author | title" mode="write-title">
    <svg:text y="{count(preceding-sibling::*) * $specs/title/line-height}">
      <xsl:apply-templates/>
    </svg:text>
  </xsl:template>
    
  <xsl:template match="text()">
    <xsl:value-of select="replace(.,'\s','&#xA0;')"/>
  </xsl:template>
  
</xsl:stylesheet>