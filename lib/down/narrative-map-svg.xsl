<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:variable name="xLMNL-document" select="/"/>
  
  <xsl:variable name="pageWidth"  select="600"/>
  <xsl:variable name="pageHeight" select="800"/>
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
    <!--<xsl:variable name="height" select="dsk:e/@height + (2 * $headExtent)"/>-->
    <xsl:variable name="svgContents">
      <xsl:apply-templates select="." mode="draw"/>
    </xsl:variable>

    <!-- The max @end is 433822 -->
    <xsl:variable name="width"
      select="ceiling(max(/x:document/x:range/@end) * $pageSqueeze) + (2 * $pageMargin)"/>
    <svg version="1.1"
      viewBox="0 0 {$pageWidth} {$pageHeight}"
      width="{$pageWidth}" height="{$pageHeight}"
      font-family="'Cambria',serif">
      
      <!--<xsl:apply-templates select="$tocMap[$debug]" mode="dsk:map-position"/>-->
      <!--<xsl:copy-of select="$legendSet"/>-->      
      
      <rect x="0" y="0" width="{$pageWidth}" height="{$pageHeight}"
            stroke-width="1" stroke="black" fill="none"/>
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
  
  <xsl:template match="dsk:*" mode="scrub">
    <xsl:apply-templates select="node() | @*" mode="scrub"/>
  </xsl:template>
  
  <xsl:template match="@dsk:*" mode="scrub"/>
    
  <!--<xsl:template match="dsk:text" mode="draw"/>-->
  
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
    <rect y="{@start * $pageSqueeze}" x="{$axis - 40}" height="{(@end - @start) * $pageSqueeze}"
      width="40" fill="none">
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
    <xsl:variable name="fromY"  select="dsk:round-and-format(dsk:scale(@start))"/>
    <xsl:variable name="toY"    select="dsk:round-and-format(dsk:scale(@end))"/>
    <xsl:variable name="leftX"  select="$axis - $leftOffset"/>
    <xsl:variable name="rightX" select="$axis + $rightOffset"/>
    <xsl:variable name="bubbleExtent"  select="dsk:scale($extent * $bubbleSqueeze)"/>
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
    <xsl:attribute name="stroke-width"     >0.01</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="formatObject">
    <xsl:attribute name="fill"             >midnightblue</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.4</xsl:attribute>
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.01</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='q']" mode="formatObject">
    <xsl:attribute name="fill"             >darkorange</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.4</xsl:attribute>
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.01</xsl:attribute>
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
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
    <xsl:attribute name="fill"             >steelblue</xsl:attribute>
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
    <xsl:value-of select="40 * (8 - count(dsk:covering(.)[@name=$narrated]))"/>
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
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="labelFormat">
    <xsl:attribute name="font-size">10</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][dsk:covering-ranges(.)/@name='letter']" mode="labelFormat" priority="2">
    <xsl:attribute name="font-size">10</xsl:attribute>
    <xsl:attribute name="fill">midnightblue</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='volume']" mode="labelFormat">
    <xsl:attribute name="font-size">14</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <!--<xsl:attribute name="text-anchor">end</xsl:attribute>-->
  </xsl:template>
  
  
  <xsl:template match="x:range[@name=('head','title')]" mode="labelFormat">
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  
  <xsl:template match="x:range[@name='chapter']" mode="labelFormat">
    <xsl:attribute name="font-size">11</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelFormat">
    <xsl:attribute name="font-size">0.2</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>

  <xsl:template match="x:range[@name='q']" mode="labelFormat">
    <xsl:attribute name="font-size">2</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="labelFormat">
    <xsl:attribute name="font-size">1.2</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="labelFormat">
    <xsl:attribute name="font-size">2</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">1</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>
  
  <!--  y="{ dsk:round-and-format(dsk:scale(@start) (: +
                 $spec/dsk:baseline :) )}" 
          x="{ $labelX }"
          font-size="{    $spec/dsk:fontSize }"
          fill="{         $spec/dsk:fontColor }"
          fill-opacity="{ $spec/dsk:fontOpacity }"
          text-anchor="{  if ($spec/dsk:indent &lt; 0) then 'end' else 'start' }"  -->
  
  
  <xsl:template match="x:range" mode="label">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="labelCoords" as="element()">
      <dsk:label>
        <xsl:apply-templates select="." mode="labelX"/>
        <xsl:apply-templates select="." mode="labelY"/>
      </dsk:label>
    </xsl:variable>

    <xsl:apply-templates select="." mode="label-path">
      <xsl:with-param name="labelCoords" select="$labelCoords"/>
    </xsl:apply-templates>
    
    <!-- Next, the label itself -->
    
    <!-- Sometimes, a label gets an extra indent by virtue
         of being assigned to a legend; when not, the indent is 0 -->
    <xsl:variable name="indent"
      select="(key('legend-line-by-ID',@ID,$legendSet)/@indent,0)[1]"/>
    <text x="{ $labelCoords/@x + $indent }" y="{ $labelCoords/@y }">
      <xsl:apply-templates  select="." mode="labelFormat"/>
      <xsl:apply-templates  select="." mode="labelText"/>
    </text>
    
    <xsl:apply-templates select="." mode="ornament-label">
      <xsl:with-param name="axis" select="$axis"/>
    </xsl:apply-templates>
    
  </xsl:template>

  <xsl:template match="x:range" mode="ornament-label"/>
  
  <xsl:template match="x:range[@name='story']" mode="ornament-label">
    <xsl:param name="axis"/>
    <path
      d="M { $axis } {dsk:round-and-format(dsk:scale(@end)) }
      Q { $axis }  {dsk:round-and-format(dsk:scale(@end) + 10) }
        { $axis - 50 }  {dsk:round-and-format(dsk:scale(@end) + 10) }">
      <xsl:apply-templates select="." mode="formatObject"/>
      <xsl:attribute name="fill">none</xsl:attribute>
    </path>
    <text x="{ $axis - 55 } " y="{number(dsk:round-and-format(dsk:scale(@end))) + 10}">
      <xsl:apply-templates select="." mode="labelFormat"/>
      <xsl:attribute name="font-size">12</xsl:attribute>
      <xsl:attribute name="text-anchor">end</xsl:attribute>
      <xsl:apply-templates select="." mode="labelText">
        <xsl:with-param name="ending" select="true()"/>
      </xsl:apply-templates>
    </text>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="label-path"/>
  
  <xsl:template match="*" mode="label-path">
    <xsl:param name="labelCoords" as="element(dsk:label)" required="yes"/>
    
      <!-- $orient is -1 for labels to the left of the axis -->
      <!--<xsl:variable name="orient"
        select="($labelCoords/@x - $axis) div abs(($labelCoords/@x - $axis))"/>-->
      <!-- $midwayX is the x between the axis and the labelX -->
      <!-- $midwayXX is the x between $midwayX and the labelX -->
      <xsl:variable name="midwayX"  select="($axis + $labelCoords/@x) div 2"/>
      <xsl:variable name="midwayXX" select="($midwayX + $labelCoords/@x) div 2"/>
      <xsl:variable name="startY"   select="dsk:round-and-format(dsk:scale(@start))"/>
      
<!--      <path
        d="M { $axis }   {dsk:round-and-format(dsk:scale(@start))}
           L { $axis + (50 * $orient)} {dsk:round-and-format(dsk:scale(@start))}
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
      select="key('legend-line-by-ID',@ID, $legendSet)/parent::dsk:legend/(@x + (@padding,0)[1])"/>
    <xsl:attribute name="x" select="$axis + $legend-indent"/>
  </xsl:template>
  
  <xsl:template mode="labelX" priority="2"
    match="x:range[@name='said'][dsk:covering-ranges(.)/@name='dialogue']">
    <xsl:variable name="legend-indent"
      select="key('legend-line-by-ID',@ID, $legendSet)/parent::dsk:legend/(@x + (@padding,0)[1])"/>
    <xsl:message>
      <xsl:value-of select="$legend-indent"/>
    </xsl:message>
    
    <xsl:attribute name="x" select="$axis + $legend-indent"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][dsk:covering-ranges(.)/@name='letter']" mode="labelX" priority="2">
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
    <xsl:attribute name="x" select="$axis - 20"/>
    <!--<xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="1000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 10) * 10) + 20 + $axis"/>-->
  </xsl:template>

  <xsl:template match="x:range[@name='page']" mode="labelX">
    <xsl:attribute name="x" select="$axis - 12"/>
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
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start))"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='story']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][dsk:covering-ranges(.)/@name='letter']" mode="labelY" priority="2">
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start))"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('chapter','letter','entry','volume','preface','introduction')]" mode="labelY">
    <!--<xsl:variable name="baseline" as="xs:double">-4</xsl:variable>-->
    <!--<xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>-->
    <xsl:attribute name="y" select="dsk:legend-y(.)"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said'][dsk:covering-ranges(.)/@name='dialogue']"
    mode="labelY" priority="2">
    <!--<xsl:message>Okay</xsl:message>-->
    <!--<xsl:variable name="baseline" as="xs:double">-4</xsl:variable>-->
    <!--<xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>-->
    <xsl:attribute name="y" select="dsk:legend-y(.)"/>
    <xsl:message>
      <xsl:value-of select="dsk:legend-y(.)"/>
    </xsl:message>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0.1</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>

  <xsl:template match="x:range[@name=('dialogue','said')]" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='q']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">-2</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='page']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">-2.5</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range">
    <xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='story']">
    <xsl:param name="ending" select="false()"/>
    <xsl:value-of select="x:annotation[@name='who']/x:content/normalize-space(.)"/>
    <xsl:text>&#xA0;</xsl:text>
    <xsl:if test="$ending">ends</xsl:if>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='chapter']">
    <xsl:text>&#xA0;Chapter </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
    <xsl:call-template name="word-count"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='entry']">
    <xsl:text>&#xA0;</xsl:text>
    <xsl:value-of select="x:annotation[@name='dateline']/x:content/normalize-space(.)"/>
    <xsl:call-template name="word-count"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='letter']">
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
  </xsl:template>
  
  <xsl:template name="word-count">
    <xsl:variable name="content" select="string-join(key('spans-for-rangeID',@ID),'')"/>
    <tspan font-size="80%">
      <xsl:text> [</xsl:text>
      <xsl:value-of select="count(tokenize($content,'\s+'))"/>
      <xsl:text>]</xsl:text>
    </tspan>
  </xsl:template>

  <xsl:template match="x:range[@name=('head','title')]" mode="labelText">
    <xsl:value-of select="string-join(key('spans-for-rangeID',@ID),'')"/>
  </xsl:template>
    
  <xsl:template mode="labelText" match="x:range[@name='said']">
    <xsl:value-of select="x:annotation[@name='who']/x:content/normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='titlePage']"/>
  
  <xsl:template mode="labelText" match="x:range[@name='volume']">
    <xsl:text>Volume </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='page']">
    <xsl:text>p. </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name=('preface','introduction')]">
    <xsl:text>&#xA0;</xsl:text>
    <xsl:value-of select="concat(upper-case(substring(@name,1,1)),substring(@name,2))"/>
    <xsl:call-template name="word-count"/>
  </xsl:template>
  
  <!--<xsl:template match="x:range[@name='story']" mode="subLabel">
    <xsl:param name="extent" as="xs:double" tunnel="yes"/>
    <text
      x="{ dsk:round-and-format(dsk:scale(@start)) }"
      y="{ dsk:round-and-format($pageAxis - (dsk:scale($extent) div 5)) }">
      <!-\-<xsl:copy-of select="$view"/>-\->
      <xsl:apply-templates select="." mode="formatLabel"/>
      <xsl:value-of select="x:annotation[@name='who']/x:content/string(.)"/>
    </text>
  </xsl:template>-->
  
  <!--<xsl:template match="x:range[@name='q']" mode="subLabel">
    <xsl:param name="extent" as="xs:double" tunnel="yes"/>
    <xsl:variable name="q" select="."/>
    <xsl:variable name="x" select="dsk:round-and-format(dsk:scale(@start) + (dsk:scale($extent) div 2) )"/>
    <xsl:variable name="y" select="dsk:round-and-format($pageAxis - (dsk:scale($extent) div 5))"/>
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
    <xsl:attribute name="cx" select="dsk:round-and-format(dsk:scale(@start + ($dimension div 2)) )"/>
    <xsl:attribute name="cy" select="$axis"/>
    <xsl:attribute name="rx" select="dsk:round-and-format(dsk:scale($dimension div 2) )"/>
    <xsl:attribute name="ry" select="dsk:round-and-format(dsk:scale($dimension div 3) )"/>
  </xsl:template>

  <!--<xsl:template match="*" mode="pageView publishedView narrativeView"/>-->
  
  <xsl:function name="dsk:scale" as="xs:double">
    <xsl:param name="measure" as="xs:double"/>
    <xsl:sequence select="$measure * $pageSqueeze"/>
  </xsl:function>
  
  <xsl:function name="dsk:round-and-format" as="xs:string">
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
    <dsk:legend rangeID="{@ID}" rangeName="body">
      <xsl:for-each
        select="/x:document/
        ( x:range[@name=('volume','introduction','preface','chapter','entry')] |
          x:range[@name='letter'][not(dsk:covering-ranges(.)/@name='chapter')] )">
        <dsk:line rangeID="{@ID}" rangeName="{@name}"/>
        <!--<xsl:copy-of select="."/>-->
      </xsl:for-each>
    </dsk:legend>
  </xsl:template>
  
  <xsl:template match="x:range[@name='dialogue']" mode="make-legend">
    <xsl:variable name="dialogue" select="."/>
    <dsk:legend rangeID="{@ID}" rangeName="dialogue">
      <xsl:for-each select="/x:document/x:range[@name='said']
        [exists(dsk:covering-ranges(.) intersect $dialogue)]">
        <dsk:line rangeID="{@ID}" rangeName="{@name}"/>
        <!--<xsl:copy-of select="."/>-->
      </xsl:for-each>
    </dsk:legend>
  </xsl:template>
  
  <xsl:template match="dsk:legend[@rangeName='body']" mode="legend-position">
    <dsk:legend x="120" y="0" padding="8" width="240"
      stroke="grey" stroke-width="1" stroke-opacity="0.4"
      fill="cornsilk" fill-opacity="0.7">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </dsk:legend>
  </xsl:template>

  <xsl:template match="dsk:legend[@rangeName='dialogue']" mode="legend-position">
    <dsk:legend x="20" padding="1" width="10"
      stroke="firebrick" stroke-width="1" stroke-opacity="0.6"
      fill="pink" fill-opacity="0.8">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="key('range-by-ID',@rangeID,$xLMNL-document)" mode="labelY"/>
      <xsl:apply-templates mode="#current"/>
    </dsk:legend>
  </xsl:template>
  
  <!--<xsl:template match="dsk:line[1]" priority="2" mode="legend-position">
    <xsl:variable name="label" as="element()">
      <dsk:label>
        <xsl:apply-templates select="key('range-by-ID',@rangeID,$xLMNL-document)" mode="labelFormat"/>
      </dsk:label>
    </xsl:variable>
    <dsk:line line-height="{($label/@font-size,'10')[1]}">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>-->
  
  <xsl:template match="dsk:line[@rangeName='volume']" mode="legend-position">
    <dsk:line line-height="20">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>
  <xsl:template match="dsk:line[@rangeName=('introduction','preface','letter')]" mode="legend-position">
    <dsk:line line-height="18" indent="10">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>
  <xsl:template match="dsk:line[@rangeName='entry']" mode="legend-position">
    <dsk:line line-height="15" indent="20">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>
  <xsl:template match="dsk:line[@rangeName='chapter']" mode="legend-position">
    <dsk:line line-height="15" indent="20">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>
  
  <xsl:template match="dsk:line[@rangeName='said']" mode="legend-position">
    <dsk:line line-height="1" indent="0.4">
      <xsl:copy-of select="@*"/>
    </dsk:line>
  </xsl:template>
  
  <xsl:key name="legend-line-by-ID" match="dsk:line" use="@rangeID"/>
  
  <xsl:function name="dsk:legend-y" as="xs:double?">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:variable name="legend-line" select="key('legend-line-by-ID',$r/@ID, $legendSet )"/>
    <xsl:sequence
      select="sum($legend-line/(.|preceding-sibling::*)/@line-height |
                  $legend-line/parent::dsk:legend/(@y|@padding) )"/>
  </xsl:function>
  
  <xsl:template match="dsk:legend" mode="draw">
    <!-- Only draws the frame for the legend or ToC; it will be filled
         in by labeling logic. -->
    <!--<dsk:legend x="180" y="0" padding="6"
      stroke="black" stroke-width="1" fill="white" fill-opacity="0.4">
      <xsl:apply-templates mode="#current"/>
    </dsk:legend>-->
    <!-- shadow should be a template -->
    <!--<rect x="{@x + $axis}" y="{@y}"
      height="{sum(.//@line-height) + (2 * @padding)}"
      width="{@width + (2 * @padding)}">
      <xsl:copy-of select="@* except (@x | @y)"/>
      <xsl:attribute name="fill">saddlebrown</xsl:attribute>
      <xsl:attribute name="fill-opacity">0.4</xsl:attribute>
    </rect>-->
    <rect x="{@x + $axis}" y="{@y}"
      height="{sum(.//@line-height) + (2 * @padding)}"
      width="{@width + (2 * @padding)}">
      <xsl:copy-of select="@* except (@x | @y)"/>
    </rect>
  </xsl:template>
  
  
  
<!--  <xsl:function name="dsk:toc-y" as="xs:decimal?">
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
  <xsl:function name="dsk:covering-ranges" as="element(x:range)*">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:sequence select="$r/key('spans-for-rangeID',@ID)/key('ranges-for-spanID',@ID)[dsk:encloses(.,$r)]"/>
  </xsl:function>

  <!-- encloses() returns true() iff $r1 encloses $r2; if they are congruent,
       it does *not* enclose. -->
  <xsl:function name="dsk:encloses" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="not($r1 is $r2) and
      ($r1/@start/number() le $r2/@start/number()) and ($r1/@end/number() ge $r2/@end/number()) and
      not($r1/@start eq $r2/@start and $r1/@end eq $r2/@end)"/>
  </xsl:function>
  

  <!--<xsl:function name="dsk:size" as="xs:double">
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