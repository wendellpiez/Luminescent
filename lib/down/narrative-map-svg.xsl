<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:lmnsc="http://wendellpiez.com/luminescent/xslt/util"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:variable name="xLMNL-document" select="/"/>
  
  <xsl:variable name="scale"         select="50"/>
  <xsl:variable name="nominalWidth"  select="19.5 * $scale"/>
  <xsl:variable name="nominalHeight" select="27.5 * $scale"/>
  
  <!-- All the font sizes are scaled to an 800-high page... -->
  <xsl:variable name="pageHeight" select="800"/>
  <xsl:variable name="pageWidth"  select="($nominalWidth div $nominalHeight) * $pageHeight"/>
  <xsl:variable name="pageMargin" select="20"/>
  
  <xsl:variable name="axis"   select="200"/>

  
  <xsl:param name="xOffset" select="0"/>
  <xsl:param name="yOffset" select="0"/>
  <xsl:param name="displayScale"  select="1"/>
  
  <!--<xsl:param name="xOffset" select="680"/>
  <xsl:param name="yOffset" select="1700"/>
  <xsl:param name="displayScale"  select="4.5"/>-->
  
  <!-- vertical axes for display of labels -->
  <xsl:variable name="leftOffset"  select="5"/>
  <xsl:variable name="rightOffset" select="5"/>

  

  <xsl:variable name="docExtent"     select="max(/x:document/x:range/@end)"/>
  <xsl:variable name="pageSqueeze"   select="($pageHeight - (2 * $pageMargin)) div $docExtent"/>

  <xsl:variable name="bubbleSqueeze" select="0.61"/>
  <!-- Calculate this dynamically? -->
  
  <xsl:output indent="yes"/>
  <!--doctype-public="-//W3C//DTD SVG 1.1//EN"
    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->

  <!--<xsl:variable name="height"     select="600"/>-->
  
  <xsl:param name="strokeWeight"  select="0.1"/>
  
  
  <xsl:template match="x:document">
    <!--<xsl:variable name="height" select="lmnsc:e/@height + (2 * $headExtent)"/>-->
    <xsl:variable name="svgContents">
      <xsl:apply-templates select="." mode="draw"/>
    </xsl:variable>

    <svg version="1.1"
      viewBox="0 0 {$pageWidth} {$pageHeight}"
      width="{$nominalWidth}" height="{$nominalHeight}"
      font-family="'Noto Serif', Cambria, serif">
      
      <!--<xsl:apply-templates select="$tocMap[$debug]" mode="lmnsc:map-position"/>-->
      <!--<xsl:copy-of select="$legendSet"/>-->      
      
      <!--<rect x="0" y="0" width="{$pageWidth}" height="{$pageHeight}"
            stroke-width="1" stroke="black" fill="none"/>-->
      <g transform="translate({$pageMargin - $xOffset} {$pageMargin - $yOffset}) scale({$displayScale})">
        <defs>
          <xsl:comment> 
            <xsl:text>SVG document map by Wendell Piez</xsl:text>
          </xsl:comment>
        </defs>
        <xsl:apply-templates select="$svgContents" mode="scrub"/>
      </g>
    </svg>
  </xsl:template>
  
  
  <xsl:variable name="debug" select="true()"/>
  
  
  <!-- Scrub mode removes anything with dsk namespace from SVG results -->
  <xsl:template match="node() | @*" mode="scrub">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="scrub"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="lmnsc:*" mode="scrub">
    <xsl:apply-templates select="node() | @*" mode="scrub"/>
  </xsl:template>
  
  <xsl:template match="@lmnsc:*" mode="scrub"/>
    
  <!--<xsl:template match="lmnsc:text" mode="draw"/>-->
  
  <xsl:variable name="divHeight" select="120"/>
  
  <xsl:variable name="textBoxWidth" select="60"/>

  <xsl:template match="x:document" mode="draw">
    
    <xsl:variable name="showRanges"
      select="'titlePage','volume','page',
      'introduction', 'preface', 'letter', 'entry',
      'chapter', 'p',  
      (: 'epigraph','lg','l', :)
      'story', 'q', 'said'
      (: 'head', 'title' :)"/>
    
    
    <xsl:variable name="pageView" select="('titlePage','page','volume')[.=$showRanges]"/>
    <xsl:variable name="narrativeView" select="('story','said','q')[.=$showRanges]"/>
    <xsl:apply-templates select="x:range[@name=$pageView]" mode="draw"/>
    <xsl:apply-templates select="x:range[@name='story']" mode="draw"/>
    <xsl:apply-templates select="$legendSet/*" mode="draw"/>
    <xsl:apply-templates select="x:range[@name=('said','q')]" mode="draw"/>
    <xsl:apply-templates select="x:range[@name=$showRanges] except x:range[@name=($pageView, $narrativeView)]" mode="draw"/>
    <!--<xsl:apply-templates select="x:range[@name='volume']" mode="draw"/>-->
  </xsl:template>

  <xsl:template match="x:range[@name=('titlePage','title-page','page')]" mode="draw">
    <rect y="{@start * $pageSqueeze}" x="{$axis - 14}" height="{(@end - @start) * $pageSqueeze}"
      width="14" fill="none">
      <xsl:apply-templates select="." mode="formatObject"/>
    </rect>
    <xsl:apply-templates select="." mode="label"/>
  </xsl:template>
  
  <!--<xsl:variable name="published" 
    select="'introduction','preface','letter','chapter','p','lg'"/>-->

  <!--<xsl:variable name="contested" select="'entry'"/>-->
  
  <!--<xsl:variable name="narrated" select="'letter','story'"/>-->
  
  
  <xsl:template match="x:range" mode="draw">
    <xsl:variable name="extent" select="@end - @start"/>
    <xsl:variable name="fromY"  select="lmnsc:round-and-format(lmnsc:scale(@start))"/>
    <xsl:variable name="toY"    select="lmnsc:round-and-format(lmnsc:scale(@end))"/>
    <xsl:variable name="leftX"  select="$axis - $leftOffset"/>
    <xsl:variable name="rightX" select="$axis + $rightOffset"/>
    <xsl:variable name="bubbleExtent"  select="lmnsc:scale($extent * $bubbleSqueeze)"/>
    <path title="{@name}"
      d="M {$leftX}  {$fromY}
         L {$rightX} {$fromY}
         C {$rightX + $bubbleExtent} {$fromY} {$rightX + $bubbleExtent} {$toY}
           {$rightX} {$toY}
         L {$leftX}  {$toY}
         C {$leftX - $bubbleExtent}  {$toY}    {$leftX - $bubbleExtent} {$fromY}
           {$leftX}  {$fromY}
         Z">
      <xsl:apply-templates select="." mode="formatObject"/>
    </path>
    <xsl:apply-templates select="." mode="label"/>
  </xsl:template>


  <xsl:template match="*" mode="formatObject"/><!-- this is the fallback, matching last -->
  
  <xsl:template match="x:range" mode="formatObject" priority="10"><!-- this is the default, matching first -->
    <xsl:attribute name="fill"             >none</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.1</xsl:attribute>
    <xsl:attribute name="stroke"           >black</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.25</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
    <xsl:next-match/>
    <!-- end of the line -->
  </xsl:template>

  <xsl:template match="x:range[@name='chapter']" mode="formatObject">
    <xsl:attribute name="stroke-width"     >1</xsl:attribute>
    <xsl:attribute name="fill"           >none</xsl:attribute>
    <xsl:attribute name="fill-opacity"   >0.6</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="formatObject">
    <xsl:attribute name="stroke-width"     >0.1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="formatObject">
    <xsl:attribute name="fill"             >midnightblue</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.4</xsl:attribute>
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.2</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='q']" mode="formatObject">
    <xsl:attribute name="fill"             >darkorange</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.4</xsl:attribute>
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter']" mode="formatObject">
    <xsl:attribute name="fill"           >none</xsl:attribute>
    <xsl:attribute name="fill-opacity"   >0.2</xsl:attribute>
    <xsl:attribute name="stroke"         >midnightblue</xsl:attribute>
    <xsl:attribute name="stroke-width"   >1</xsl:attribute>
    <xsl:attribute name="stroke-opacity" >0.6</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >5 1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="formatObject">
    <xsl:attribute name="fill"           >none</xsl:attribute>
    <xsl:attribute name="fill-opacity"   >0.2</xsl:attribute>
    <xsl:attribute name="stroke"         >midnightblue</xsl:attribute>
    <xsl:attribute name="stroke-width"   >1</xsl:attribute>
    <xsl:attribute name="stroke-opacity" >0.8</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >4 1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  
  <xsl:template match="x:range[@name='story']" mode="formatObject">
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >3</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >2 2</xsl:attribute>
    <xsl:attribute name="fill"             >rosybrown</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='volume']" mode="formatObject">
    <xsl:attribute name="stroke"           >midnightblue</xsl:attribute>
    <xsl:attribute name="stroke-width"     >2</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >2 2</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
    <xsl:attribute name="fill"             >white</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="formatObject">
    <xsl:attribute name="stroke"           >black</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.1</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <!--<xsl:template match="x:range[@name=$narrated]" mode="height">
    <xsl:value-of select="40 * (8 - count(lmnsc:covering(.)[@name=$narrated]))"/>
  </xsl:template>-->
  
  <!--<xsl:template match="x:range[@name=('letter')]" mode="height">150</xsl:template>-->
  
  <xsl:template match="x:range" mode="labelFormat">
    <xsl:attribute name="font-size">14</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='story']" mode="labelFormat">
    <xsl:attribute name="font-size">18</xsl:attribute>
    <xsl:attribute name="fill">darkred</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.8</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter']" mode="labelFormat">
    <xsl:attribute name="font-size">14</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="labelFormat">
    <xsl:attribute name="font-size">9</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][lmnsc:covering-ranges(.)/@name='letter']" mode="labelFormat" priority="2">
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='chapter']" mode="labelFormat">
    <xsl:attribute name="font-size">11</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelFormat">
    <xsl:attribute name="font-size">0.4</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('head','title')]" mode="labelFormat">
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='q']" mode="labelFormat">
    <xsl:attribute name="font-size">2</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="labelFormat">
    <xsl:attribute name="font-size">2.4</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='volume']" mode="labelFormat">
    <xsl:attribute name="font-size">10</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <!--<xsl:attribute name="text-anchor">end</xsl:attribute>-->
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="labelFormat">
    <xsl:attribute name="font-size">2</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>

  <xsl:template match="lmnsc:*" mode="labelFormat">
    <xsl:attribute name="font-size">14</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="lmnsc:cartouche[@rangeName='body']" mode="labelFormat">
    <xsl:attribute name="stroke">grey</xsl:attribute>
    <xsl:attribute name="stroke-width">1</xsl:attribute>
    <xsl:attribute name="stroke-opacity">0.4</xsl:attribute>
    <xsl:attribute name="fill">cornsilk</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.7</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="lmnsc:cartouche[@rangeName='dialogue']" mode="labelFormat">
    <xsl:attribute name="stroke">indianred</xsl:attribute>
    <xsl:attribute name="stroke-width">0.3</xsl:attribute>
    <xsl:attribute name="stroke-opacity">0.4</xsl:attribute>
    <xsl:attribute name="fill">cornsilk</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.8</xsl:attribute>
  </xsl:template>
  
  
  <!--  y="{ lmnsc:round-and-format(lmnsc:scale(@start) (: +
                 $spec/lmnsc:baseline :) )}" 
          x="{ $labelX }"
          font-size="{    $spec/lmnsc:fontSize }"
          fill="{         $spec/lmnsc:fontColor }"
          fill-opacity="{ $spec/lmnsc:fontOpacity }"
          text-anchor="{  if ($spec/lmnsc:indent &lt; 0) then 'end' else 'start' }"  -->
  
  
  
  <!-- Suppress the labeling of 'said' elements if they appear in a 'dialogue' legend,
       but not first with the same @saidWho marked on the line -->
  <!--<xsl:template match="x:range[@name='said']
    [not(key('legend-line-by-ID',@ID, $legendSet )/
         preceding-sibling::lmnsc:line/@saidWho
         = x:annotation[@name='who']/x:content/string(.) )]"
         mode="label"/>-->
 
  

  <xsl:template match="x:range" mode="label">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="labelCoords" as="element()">
      <lmnsc:label>
        <xsl:apply-templates select="." mode="labelX"/>
        <xsl:apply-templates select="." mode="labelY"/>
      </lmnsc:label>
    </xsl:variable>

    <xsl:apply-templates select="." mode="label-path">
      <xsl:with-param name="labelCoords" select="$labelCoords"/>
    </xsl:apply-templates>
    
    <!-- Next, the label itself, unless it is to appear in a legend
         (floating cartouche) -->
    
    <!--<xsl:if test="empty(key('legend-line-by-ID',@ID,$legendSet))">-->
      
    <!-- Sometimes, a label gets an extra indent by virtue
         of being assigned to a legend; when not, the indent is 0 -->
    <xsl:variable name="indent"
      select="(key('legend-line-by-ID',@ID,$legendSet)/@indent,0)[1]"/>
    <!--<text x="{ $labelCoords/@x + $indent }" y="{ $labelCoords/@y }">
      <xsl:apply-templates  select="." mode="labelFormat"/>
      <xsl:apply-templates  select="." mode="labelText"/>
    </text>-->
    <g transform="translate({ $labelCoords/@x + $indent } { $labelCoords/@y })">
      <xsl:apply-templates  select="." mode="labelFormat"/>
      <xsl:apply-templates  select="." mode="labelText"/>
    </g>
    
    <xsl:apply-templates select="." mode="ornament-label">
      <xsl:with-param name="axis" select="$axis"/>
    </xsl:apply-templates>
    <!--</xsl:if>-->
    
  </xsl:template>

  <xsl:template match="x:range" mode="ornament-label"/>
  
  <xsl:template match="x:range[@name='story']" mode="ornament-label">
    <xsl:param name="axis"/>
    <path
      d="M { $axis } {lmnsc:round-and-format(lmnsc:scale(@end)) }
      Q { $axis }  {lmnsc:round-and-format(lmnsc:scale(@end) + 10) }
        { $axis - 50 }  {lmnsc:round-and-format(lmnsc:scale(@end) + 10) }">
      <xsl:apply-templates select="." mode="formatObject"/>
      <xsl:attribute name="fill">none</xsl:attribute>
    </path>
    <g transform="translate({ $axis - 55 } {number(lmnsc:round-and-format(lmnsc:scale(@end))) + 10})">
      <xsl:apply-templates select="." mode="labelFormat"/>
      <xsl:attribute name="font-size">12</xsl:attribute>
      <xsl:attribute name="text-anchor">end</xsl:attribute>
      <xsl:apply-templates select="." mode="labelText">
        <xsl:with-param name="ending" select="true()"/>
      </xsl:apply-templates>
    </g>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="label-path"/>
  
  <xsl:template match="*" mode="label-path">
    <xsl:param name="labelCoords" as="element(lmnsc:label)" required="yes"/>
    
      <!-- $orient is -1 for labels to the left of the axis -->
      <!--<xsl:variable name="orient"
        select="($labelCoords/@x - $axis) div abs(($labelCoords/@x - $axis))"/>-->
      <!-- $midwayX is the x between the axis and the labelX -->
      <!-- $midwayXX is the x between $midwayX and the labelX -->
      <xsl:variable name="midwayX"  select="($axis + $labelCoords/@x) div 2"/>
      <xsl:variable name="midwayXX" select="($midwayX + $labelCoords/@x) div 2"/>
      <xsl:variable name="startY"   select="lmnsc:round-and-format(lmnsc:scale(@start))"/>
      
<!--      <path
        d="M { $axis }   {lmnsc:round-and-format(lmnsc:scale(@start))}
           L { $axis + (50 * $orient)} {lmnsc:round-and-format(lmnsc:scale(@start))}
           L { $labelCoords/@x - 10 } { $labelCoords/@y } h {20 * $orient}">
-->
    <path
      d="M { $axis }   { $startY }
         C { $midwayX } { $startY }
           { $midwayXX } { $labelCoords/@y }
           { $labelCoords/@x } { $labelCoords/@y }">
      
    <xsl:apply-templates select="." mode="formatObject"/>
        <xsl:attribute name="fill">none</xsl:attribute>
    </path>

  </xsl:template>
  
  <xsl:template match="x:range" mode="labelX">
    <xsl:attribute name="x" select="$axis + 10"/>
  </xsl:template>


  
  <!--<xsl:template match="x:range[@name='letter']" mode="labelX">
    <!-\-<xsl:variable name="start" select="number(@start)"/>-\->
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="10000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 2) * 60) + 130 + $axis"/>
  </xsl:template>-->
  
  <!--<xsl:template match="x:range[@name='entry']" mode="labelX">
    <xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="10000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 3) * 35) + 260 + $axis"/>
  </xsl:template>-->

  <xsl:template mode="labelX"
    match="x:range[@name=('volume','introduction','preface','letter','chapter','entry')]">
    <xsl:variable name="legend-indent"
      select="key('legend-line-by-ID',@ID, $legendSet)/parent::lmnsc:cartouche/(@x + (@padding,0)[1])"/>
    <xsl:attribute name="x" select="$legend-indent"/>
  </xsl:template>
  
  <xsl:template mode="labelX" priority="2"
    match="x:range[@name='said'][lmnsc:covering-ranges(.)/@name='dialogue']">
    <xsl:variable name="legend-indent"
      select="key('legend-line-by-ID',@ID, $legendSet)/parent::lmnsc:cartouche/(@x + (@padding,0)[1])"/>
    <xsl:attribute name="x" select="$legend-indent"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][lmnsc:covering-ranges(.)/@name='letter']" mode="labelX" priority="2">
    <xsl:attribute name="x" select="$axis - 80"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='story']" mode="labelX">
    <xsl:attribute name="x" select="$axis - 100"/>
  </xsl:template>
  
  
  <xsl:template match="x:range[@name='p']" mode="labelX">
    <xsl:attribute name="x" select="$axis + 8"/>
  </xsl:template>

  <xsl:template match="x:range[@name='q']" mode="labelX">
    <xsl:attribute name="x" select="$axis + 15"/>
    <!--<xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="1000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 2) * 4) + 12 + $axis"/>-->
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="labelX">
    <xsl:attribute name="x" select="$axis + 20"/>
    <!--<xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="1000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 10) * 10) + 20 + $axis"/>-->
  </xsl:template>

  <xsl:template match="x:range[@name='page']" mode="labelX">
    <xsl:attribute name="x" select="$axis - 7"/>
  </xsl:template>
  
  <xsl:template match="x:range" mode="pullPrecedents" as="element()+">
    <!-- Recursively finds ranges of the same type within a buffer region preceding
         the given range. -->
    <xsl:param name="buffer" as="xs:double" required="yes" tunnel="yes"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="start" select="@start"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents"
        select="preceding-sibling::x:range[@name=$name][1][@start &gt;= ($start - $buffer)]"/>
    </xsl:variable>
    <xsl:sequence select=".,$precedents"/>
  </xsl:template>
  
<!-- ================== -->

  <xsl:template match="x:range" mode="labelY">
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start))"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='story']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0</xsl:variable>
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][lmnsc:covering-ranges(.)/@name='letter']" mode="labelY" priority="2">
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start))"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('chapter','letter','entry','volume','preface','introduction')]" mode="labelY">
    <!--<xsl:variable name="baseline" as="xs:double">-4</xsl:variable>-->
    <!--<xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>-->
    <xsl:attribute name="y" select="lmnsc:range-legend-y(.)"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said'][lmnsc:covering-ranges(.)/@name='dialogue']"
    mode="labelY" priority="2">
    <!--<xsl:message>Okay</xsl:message>-->
    <!--<xsl:variable name="baseline" as="xs:double">-4</xsl:variable>-->
    <!--<xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>-->
    <xsl:attribute name="y" select="lmnsc:range-legend-y(.)"/>
    <!--<xsl:message>
      <xsl:value-of select="lmnsc:legend-y(.)"/>
    </xsl:message>-->
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0.1</xsl:variable>
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>
  </xsl:template>

  <xsl:template match="x:range[@name=('dialogue','said')]" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0</xsl:variable>
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='q']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">2</xsl:variable>
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">-2.5</xsl:variable>
    <xsl:attribute name="y" select="lmnsc:round-and-format(lmnsc:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range">
    <text>
      <xsl:value-of select="@name"/>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='story']">
    <xsl:param name="ending" select="false()"/>
    <text>
    <xsl:value-of select="x:annotation[@name='who']/x:content/normalize-space(.)"/>
    <xsl:text>&#xA0;</xsl:text>
    <xsl:if test="$ending">ends</xsl:if>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='chapter']">
    <text>
    <xsl:text>&#xA0;Chapter </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
    <xsl:call-template name="word-count"/>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='entry']">
    <text>
    <xsl:text>&#xA0;</xsl:text>
    <xsl:value-of select="x:annotation[@name='dateline']/x:content/normalize-space(.)"/>
    <xsl:call-template name="word-count"/>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='letter']">
    <text>
    <xsl:text>&#xA0;Letter </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
    <xsl:for-each select="x:annotation[@name='dateline']">
      <tspan font-size="80%">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="x:content/normalize-space(.)"/>
        <xsl:text>)</xsl:text>
      </tspan>
    </xsl:for-each>
    <xsl:call-template name="word-count"/>
    </text>
    <xsl:if test="lmnsc:covering-ranges(.)/@name='letter'">
      <text y="8" font-size="45%">
        <xsl:for-each select="x:annotation[@name='from']">
          <xsl:value-of select="x:content/normalize-space(.)"/>
        </xsl:for-each>
        <xsl:for-each select="x:annotation[@name='to']">
          <xsl:value-of select="if (not(../x:annotation/@name='from')) then 'To' else ' to '"/>
          <xsl:value-of select="x:content/normalize-space(.)"/>
        </xsl:for-each>
        
      </text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="word-count">
    <xsl:variable name="content" select="string-join(key('spans-for-rangeID',@ID),'')"/>
    <tspan font-size="80%">
      <xsl:text> [</xsl:text>
      <xsl:value-of select="count(tokenize($content,'\s+'))"/>
      <xsl:if test="@name='introduction'"> words</xsl:if>
      <xsl:text>]</xsl:text>
    </tspan>
  </xsl:template>

  <xsl:template match="x:range[@name=('head','title')]" mode="labelText">
    <text>
      <xsl:value-of select="string-join(key('spans-for-rangeID',@ID),'')"/>
    </text>
  </xsl:template>
    
  <xsl:template mode="labelText" match="x:range[@name='said']">
    <text>
    <xsl:value-of select="x:annotation[@name='who']/x:content/normalize-space(.)"/>
    <xsl:for-each select="key('legend-line-by-ID',@ID, $legendSet )/@rangeCount">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" priority="2"
    match="x:range[@name='said'][lmnsc:covering-ranges(.)/@name='dialogue']">
    <!-- We only want the label if this is the first said within its dialogue range
         with the given value of x:annotation[@name='who']/x:content/string(.) i.e. @who -->
    <xsl:variable name="who" select="x:annotation[@name='who']/x:content/string(.)"/>
    <!-- <xsl:message>Matched</xsl:message> -->
    <xsl:if test=". is 
      key('said-ranges-for-dialogue',lmnsc:covering-ranges(.)[@name='dialogue']/@ID)
      [x:annotation[@name='who']/x:content/string(.)=$who][1]">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  <!--x:range[@name='said'][lmnsc:covering-ranges(.)/@name='dialogue']-->
  
  <xsl:key name="said-ranges-for-dialogue"
    match="x:range[@name='said'][lmnsc:covering-ranges(.)/@name='dialogue']"
    use="lmnsc:covering-ranges(.)[@name='dialogue']/@ID"/>
  
  
  
  <xsl:template mode="labelText" match="x:range[@name='titlePage']"/>
  
  <xsl:template mode="labelText" match="x:range[@name='volume']">
    <text>
    <xsl:text>Volume </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='page']">
    <text>
    <xsl:text>p. </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
    </text>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name=('preface','introduction')]">
    <text>
    <xsl:text>&#xA0;</xsl:text>
    <xsl:value-of select="concat(upper-case(substring(@name,1,1)),substring(@name,2))"/>
    <xsl:call-template name="word-count"/>
    </text>
  </xsl:template>
  
  <!--<xsl:template match="x:range[@name='story']" mode="subLabel">
    <xsl:param name="extent" as="xs:double" tunnel="yes"/>
    <text
      x="{ lmnsc:round-and-format(lmnsc:scale(@start)) }"
      y="{ lmnsc:round-and-format($pageAxis - (lmnsc:scale($extent) div 5)) }">
      <!-\-<xsl:copy-of select="$view"/>-\->
      <xsl:apply-templates select="." mode="formatLabel"/>
      <xsl:value-of select="x:annotation[@name='who']/x:content/string(.)"/>
    </text>
  </xsl:template>-->
  
  <!--<xsl:template match="x:range[@name='q']" mode="subLabel">
    <xsl:param name="extent" as="xs:double" tunnel="yes"/>
    <xsl:variable name="q" select="."/>
    <xsl:variable name="x" select="lmnsc:round-and-format(lmnsc:scale(@start) + (lmnsc:scale($extent) div 2) )"/>
    <xsl:variable name="y" select="lmnsc:round-and-format($pageAxis - (lmnsc:scale($extent) div 5))"/>
    <xsl:for-each select="('90','270')">
    <text title="{$q/@name}">
      <!-\-<xsl:copy-of select="$view"/>-\->
      <xsl:apply-templates select="$q" mode="formatLabel"/>
      <xsl:attribute name="transform">
        <xsl:text>translate (</xsl:text>
        <xsl:value-of select="$x, $y" separator=" "/>
        <xsl:text>) rotate(</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="$q/x:annotation[@name='who']/x:content/string(.)"/>
    </text>
    </xsl:for-each>
  </xsl:template>-->
  
  
  <xsl:template name="oval">
    <xsl:param name="dimension" as="xs:double"/>
    <xsl:attribute name="cx" select="lmnsc:round-and-format(lmnsc:scale(@start + ($dimension div 2)) )"/>
    <xsl:attribute name="cy" select="$axis"/>
    <xsl:attribute name="rx" select="lmnsc:round-and-format(lmnsc:scale($dimension div 2) )"/>
    <xsl:attribute name="ry" select="lmnsc:round-and-format(lmnsc:scale($dimension div 3) )"/>
  </xsl:template>

  <!--<xsl:template match="*" mode="pageView publishedView narrativeView"/>-->
  
  <xsl:function name="lmnsc:scale" as="xs:double">
    <xsl:param name="measure" as="xs:double"/>
    <xsl:sequence select="$measure * $pageSqueeze"/>
  </xsl:function>
  
  <xsl:function name="lmnsc:round-and-format" as="xs:string">
    <xsl:param name="value" as="xs:double"/>
    <xsl:value-of select="format-number($value,'0.00000')"/>
  </xsl:function>
  
  
  <xsl:variable name="legendSet">
    <xsl:variable name="bareLegends">
      <xsl:apply-templates select="/x:document/x:range[@name=('body','dialogue')]" mode="make-legend"/>
    </xsl:variable>
    <!--<bare>
    <xsl:copy-of select="$bareLegends"/>
    </bare>-->
    <xsl:apply-templates select="$bareLegends" mode="legend-position"/>
  </xsl:variable>

  <xsl:template match="x:range[@name='body']" mode="make-legend">
    <lmnsc:cartouche rangeID="{@ID}" rangeName="body">
      <xsl:for-each
        select="/x:document/
        ( x:range[@name=('volume','introduction','preface','chapter','entry')] |
        x:range[@name='letter'][not(lmnsc:covering-ranges(.)/@name='chapter')] )">
        <lmnsc:line rangeID="{@ID}" rangeName="{@name}"/>
      </xsl:for-each>
      <!--<xsl:for-each
        select="/x:document/
        x:range[@name='letter']
               [not(lmnsc:covering-ranges(.)/@name='chapter')]
               [x:annotation/@name='to']">
        <lmnsc:line rangeID="{@ID}" rangeName="letter-to"/>
      </xsl:for-each>-->
    </lmnsc:cartouche>
  </xsl:template>
  
  <xsl:template match="x:range[@name='dialogue']" mode="make-legend">
    <xsl:variable name="dialogue" select="."/>
    <lmnsc:cartouche rangeID="{@ID}" rangeName="dialogue" start="{@start}" end="{@end}">
      <!--<xsl:for-each select="/x:document/x:range[@name='said']
        [exists(lmnsc:covering-ranges(.) intersect $dialogue)]">
        <lmnsc:line rangeID="{@ID}" rangeName="{@name}"/>
        <!-\-<xsl:copy-of select="."/>-\->
      </xsl:for-each>-->
      <xsl:for-each-group
        select="key('said-ranges-for-dialogue',@ID)"
        group-by="x:annotation[@name='who']/x:content">
        <!-- Representing some semantics for presentation logic -->
        <lmnsc:line rangeID="{string-join(current-group()/@ID,' ')}" rangeName="said"
                  rangeCount="{count(current-group())}" saidWho="{current-grouping-key()}"/>
        <!--<xsl:copy-of select="."/>-->
      </xsl:for-each-group>
    </lmnsc:cartouche>
  </xsl:template>
  
  <xsl:template match="lmnsc:cartouche[@rangeName='body']" mode="legend-position">
    <xsl:variable name="lines" as="element()*">
      <xsl:apply-templates mode="#current"/>
    </xsl:variable>
    <xsl:variable name="padding" select="4"/>
    <xsl:variable name="boxSize" select="sum($lines/@line-height) + (2 * $padding)"/>
    <lmnsc:cartouche x="{$axis + 120 }" y="{0}" padding="{$padding}" width="200" height="{ $boxSize }">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </lmnsc:cartouche>
  </xsl:template>

  <xsl:template match="lmnsc:cartouche[@rangeName='dialogue']" mode="legend-position">
    <xsl:variable name="lines" as="element()*">
      <xsl:apply-templates mode="#current"/>
    </xsl:variable>
    <xsl:variable name="padding" select="0.5"/>
    <xsl:variable name="boxSize" select="sum($lines/@line-height) + (2 * $padding)"/>
    <xsl:variable name="y" select="lmnsc:round-and-format(lmnsc:scale((@start + @end) div 2) - ($boxSize div 2))"/>
    
    <xsl:variable name="predecessor" as="element()?">
      <xsl:apply-templates select="preceding-sibling::lmnsc:cartouche[@rangeName='dialogue'][1]" mode="legend-position"/>
    </xsl:variable>
    <xsl:variable name="predecessor-bottom" select="($predecessor/(@y + @height),0)[1]"/>
    <xsl:variable name="impinging" select="$predecessor-bottom gt number($y)"/>
    <lmnsc:cartouche width="22" height="{$boxSize}"
      x="{ if ($impinging) then ($predecessor/@x + 24 ) else ($axis + 40)}" padding="{$padding}"
      y="{ lmnsc:round-and-format(lmnsc:scale((@start + @end) div 2) - ($boxSize div 2)) }">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </lmnsc:cartouche>
  </xsl:template>
  
  
  <xsl:template match="lmnsc:line[@rangeName='volume']" mode="legend-position">
    <lmnsc:line line-height="16">
      <xsl:attribute name="text-anchor">start</xsl:attribute>
      <xsl:copy-of select="@*"/>
      <!-- overriding line-height for the first one -->
      <xsl:call-template name="firstLine-lineHeight"/>
    </lmnsc:line>
  </xsl:template>
  
  <xsl:template name="firstLine-lineHeight">
    <xsl:if test="empty(preceding-sibling::lmnsc:line)">
      <xsl:variable name="labelFormat" as="element()">
        <lmnsc:label>
          <xsl:apply-templates
            select="key('range-by-ID',@rangeID/tokenize(.,'\s+'),$xLMNL-document)[1]"
            mode="labelFormat"/>
        </lmnsc:label>
      </xsl:variable>
      <xsl:attribute name="line-height" select="($labelFormat/@font-size,'0')[1]"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="lmnsc:line[@rangeName=('introduction','preface','letter')]" mode="legend-position">
    <lmnsc:line line-height="18" indent="10">
      <xsl:copy-of select="@*"/>
    </lmnsc:line>
  </xsl:template>
  <xsl:template match="lmnsc:line[@rangeName='letter-to']" mode="legend-position">
    <lmnsc:line line-height="16" indent="15">
      <xsl:copy-of select="@*"/>
    </lmnsc:line>
  </xsl:template>
  <xsl:template match="lmnsc:line[@rangeName='entry']" mode="legend-position">
    <lmnsc:line line-height="14" indent="20">
      <xsl:copy-of select="@*"/>
    </lmnsc:line>
  </xsl:template>
  <xsl:template match="lmnsc:line[@rangeName='chapter']" mode="legend-position">
    <lmnsc:line line-height="16" indent="20">
      <xsl:copy-of select="@*"/>
    </lmnsc:line>
  </xsl:template>
  <xsl:template match="lmnsc:line[@rangeName='said']" mode="legend-position">
    <lmnsc:line line-height="3" indent="0.4">
      <xsl:copy-of select="@*"/>
      <!-- overriding line-height for the first one -->
      <xsl:call-template name="firstLine-lineHeight"/>
    </lmnsc:line>
  </xsl:template>
  
  <!-- A single legend line can be bound to any number of ranges.
       Also, more than one legend line might be emitted for a given range; i.e.
       the key may return several lines. -->
  <xsl:key name="legend-line-by-ID" match="lmnsc:line" use="tokenize(@rangeID,'\s+')"/>
  
  <xsl:function name="lmnsc:range-legend-y" as="xs:double?">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:variable name="legend-line" select="key('legend-line-by-ID',$r/@ID, $legendSet )[1]"/>
    <xsl:sequence
      select="sum($legend-line/(.|preceding-sibling::*)/@line-height |
      $legend-line/parent::lmnsc:cartouche/@y )"/>
  </xsl:function>
  
  
  <xsl:template match="lmnsc:cartouche" mode="draw">
    <!-- Just drawing the box - lines are handled elsewhere (by labeling ranges) -->
    <rect >
      <!-- includes height and width -->
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="." mode="labelFormat"/>
    </rect>
    <!--<xsl:apply-templates select="lmnsc:line" mode="draw"/>-->
  </xsl:template>
  
  <!--<xsl:template match="lmnsc:line" mode="draw">
    <xsl:variable as="element(text)*" name="line-text">
      <xsl:apply-templates select="key('range-by-ID',@rangeID)" mode="labelText"/>
    </xsl:variable>
    <xsl:for-each select="$line-text">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="y"
          select="sum((.|preceding-sibling::*)/@line-height |
                      parent::lmnsc:cartouche/@y )"/>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>-->
  
  
<!--  <xsl:function name="lmnsc:toc-y" as="xs:decimal?">
    <xsl:param name="r" as="element(x:range)"/>\
    <xsl:variable name="map-item" select="key('toc-map-item',$r/@ID,$tocMap)"/>
    <xsl:sequence select="sum($map-item/(.|preceding-sibling::*|..)/(@line-height | @y) )"/>
  </xsl:function>
  
-->  
  <xsl:key name="range-by-ID" match="x:range" use="@ID"/>

  <xsl:key name="ranges-for-spanID" match="x:range" use="tokenize(@spans,'\s+')"/>
  
  <xsl:key name="spans-for-rangeID" match="x:span"  use="tokenize(@ranges,'\s+')"/>
  
  <!-- covering-ranges() returns all the ranges covering a given range
       ('ancestors' in XML parlance) -->
  <xsl:function name="lmnsc:covering-ranges" as="element(x:range)*">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:sequence select="$r/key('spans-for-rangeID',@ID)/key('ranges-for-spanID',@ID)[lmnsc:encloses(.,$r)]"/>
  </xsl:function>

  <!-- encloses() returns true() iff $r1 encloses $r2; if they are congruent,
       it does *not* enclose. -->
  <xsl:function name="lmnsc:encloses" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="not($r1 is $r2) and
      ($r1/@start/number() le $r2/@start/number()) and ($r1/@end/number() ge $r2/@end/number()) and
      not($r1/@start eq $r2/@start and $r1/@end eq $r2/@end)"/>
  </xsl:function>
  

  <!--<xsl:function name="lmnsc:size" as="xs:double">
    <!-\- makes lines and scale bolder for larger things, but not linearly -\->
    <xsl:param name="extent" as="xs:double"/>
    <xsl:variable name="extent-sqrt">
    <xsl:call-template name="math:sqrt">
      <xsl:with-param name="number" select="$extent"/>
    </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="$extent-sqrt div 500"/>
  </xsl:function>-->


<!--  <xsl:template name="math:sqrt" as="xs:double">
    <!-\-  The number you want to find the square root of  -\->
    <xsl:param name="number"
      select="0" />
    <!-\-  The current 'try'.  This is used internally.  -\->
    <xsl:param name="try"
      select="1" />
    <!-\-  The current iteration, checked against maxiter to limit loop count  -\->
    <xsl:param name="iter"
      select="1" />
    <!-\-  Set this up to ensure against infinite loops  -\->
    <xsl:param name="maxiter"
      select="20" />
    <!-\-  This template was written by Nate Austin using Sir Isaac Newton's
       method of finding roots  -\->
    <xsl:choose>
      <xsl:when test="$try * $try = $number or $iter > $maxiter">
        <xsl:value-of select="$try" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="math:sqrt">
          <xsl:with-param name="number"
            select="$number" />
          <xsl:with-param name="try"
            select="$try - (($try * $try - $number) div (2 * $try))" />
          <xsl:with-param name="iter"
            select="$iter + 1" />
          <xsl:with-param name="maxiter"
            select="$maxiter" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->  
  
  
</xsl:stylesheet>