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
  
<!-- Rather early attempt. -->
  
  
  <xsl:variable name="pageWidth"  select="600"/>
  <xsl:variable name="pageHeight" select="800"/>
  <xsl:variable name="pageMargin" select="20"/>
  
  <xsl:variable name="axis"   select="200"/>

  <xsl:param name="xOffset"      select="0"/>
  <xsl:param name="yOffset"      select="0"/>
  <xsl:param name="displayScale" select="1"/>
  
  <!-- close up on initial segment:
    <xsl:param name="xOffset" select="720"/>
  <xsl:param name="yOffset" select="-20"/>
  <xsl:param name="displayScale"  select="4"/>-->
  
  <!--close up on the final segment:
    <xsl:param name="xOffset" select="860"/>
  <xsl:param name="yOffset" select="2520"/>
  <xsl:param name="displayScale"  select="5.5"/> -->
  
  <!-- vertical axes for display of labels -->
  <xsl:variable name="leftOffset"  select="5"/>
  <xsl:variable name="rightOffset" select="5"/>

  

  <xsl:variable name="docExtent"     select="max(/x:document/x:range/@end)"/>
  <xsl:variable name="pageSqueeze"   select="($pageHeight - (2 * $pageMargin)) div $docExtent"/>

  <xsl:variable name="bubbleSqueeze" select="0.61"/>
  <!-- Calculate this dynamically? -->
  
  <xsl:variable name="showRanges"
    select="'titlePage','page',
    'introduction', 'preface',
    'chapter', 'p',
    'letter', 'entry',
    (: 'epigraph','lg','l', :)
    'story', 'q', 'said'
    (: 'head', 'title' :)"/>

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

    <!--<xsl:variable name="width" select="(max($svgContents//@dsk:xBound))
      + (2 * $inter)"/>
    <xsl:variable name="height" select="(max($svgContents//@dsk:yBound))
      + (2 * $inter)"/>-->
    <!-- The max @end is 433822 -->
    <xsl:variable name="width"
      select="ceiling(max(/x:document/x:range/@end) * $pageSqueeze) + (2 * $pageMargin)"/>
    
    <!--<xsl:message>
      <xsl:text>$squeeze is </xsl:text>
      <xsl:value-of select="$squeeze"/>
    </xsl:message>-->
    <!--<svg version="1.1"
      viewBox="0 0 800 {$height}" width="800" height="{$height}">-->
    <svg version="1.1"
      viewBox="0 0 {$pageWidth} {$pageHeight}"
      width="{$pageWidth}" height="{$pageHeight}"
      font-family="'Cambria',serif">
      <rect x="0" y="0" width="{$pageWidth}" height="{$pageHeight}"
        stroke-width="1" stroke="black" fill="#9c9ccf"/>
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
    <xsl:variable name="pageView" select="('titlePage','page')[.=$showRanges]"/>
    <xsl:variable name="narrativeView" select="('story','said','q')[.=$showRanges]"/>
    <xsl:apply-templates select="x:range[@name=$pageView]" mode="draw"/>
    <xsl:apply-templates select="x:range[@name=$showRanges] except x:range[@name=($pageView, $narrativeView)]" mode="draw"/>
    <xsl:apply-templates select="x:range[@name=$narrativeView]" mode="draw"/>
  </xsl:template>

  <xsl:template match="x:range[@name=('titlePage','page')]" mode="draw">
    <rect y="{@start * $pageSqueeze}" x="{$axis - 40}" height="{(@end - @start) * $pageSqueeze}"
      width="40" stroke-width="{$strokeWeight}" stroke="black" fill="none">
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

  <xsl:template match="x:range[@name='page']" mode="formatObject">
    <xsl:attribute name="fill"             >white</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >1</xsl:attribute>
    <xsl:attribute name="stroke"           >black</xsl:attribute>
    <xsl:attribute name="stroke-width"     >0.25</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('introduction','preface','chapter')]" mode="formatObject">
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
    <xsl:attribute name="fill"             >purple</xsl:attribute>
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
    <xsl:attribute name="stroke"         >saddlebrown</xsl:attribute>
    <xsl:attribute name="stroke-width"   >1</xsl:attribute>
    <xsl:attribute name="stroke-opacity" >0.2</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >5 1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="formatObject">
    <xsl:attribute name="fill"           >none</xsl:attribute>
    <xsl:attribute name="fill-opacity"   >0.2</xsl:attribute>
    <xsl:attribute name="stroke"         >#633030</xsl:attribute>
    <xsl:attribute name="stroke-width"   >0.5</xsl:attribute>
    <xsl:attribute name="stroke-opacity" >0.8</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >4 1</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  
  <xsl:template match="x:range[@name='story']" mode="formatObject">
    <xsl:attribute name="fill"             >lemonchiffon</xsl:attribute>
    <xsl:attribute name="fill-opacity"     >0.2</xsl:attribute>
    <xsl:attribute name="stroke"           >darkred</xsl:attribute>
    <xsl:attribute name="stroke-width"     >3</xsl:attribute>
    <xsl:attribute name="stroke-opacity"   >0.5</xsl:attribute>
    <xsl:attribute name="stroke-dasharray" >2 2</xsl:attribute>
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
    <xsl:attribute name="font-size">14</xsl:attribute>
    <xsl:attribute name="fill">saddlebrown</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="labelFormat">
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="fill">#633030</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][dsk:covering(.)/@name='letter']" mode="labelFormat" priority="2">
    <xsl:attribute name="font-size">12</xsl:attribute>
    <xsl:attribute name="fill">saddlebrown</xsl:attribute>
    <xsl:attribute name="text-anchor">end</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='chapter']" mode="labelFormat">
    <xsl:attribute name="font-size">11</xsl:attribute>
    <xsl:attribute name="fill">black</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.8</xsl:attribute>
    <xsl:attribute name="text-anchor">start</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelFormat">
    <xsl:attribute name="font-size">0.2</xsl:attribute>
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
    <xsl:attribute name="font-size">1.5</xsl:attribute>
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
    <!--<xsl:variable name="spec" select="($labelSpecs[@name=$name],$labelSpecs/self::dsk:default)[1]"/>-->
    <xsl:variable name="labelCoords" as="element()">
      <dsk:label>
        <xsl:apply-templates select="." mode="labelX"/>
        <xsl:apply-templates select="." mode="labelY"/>
      </dsk:label>
    </xsl:variable>
    
    <xsl:if test="not(@name='page')">
      <path d="M { $axis }   {dsk:round-and-format(dsk:scale(@start))}
        L { $labelCoords/@x} {dsk:round-and-format(dsk:scale(@start))}
        L { $labelCoords/@x} { $labelCoords/@y } ">
        <xsl:apply-templates select="." mode="formatObject"/>
        <xsl:attribute name="fill">none</xsl:attribute>
      </path>
      
      <!--<line x1="{ $axis }"
            y1="{ dsk:round-and-format(dsk:scale(@start)) }"
            x2="{ $labelCoords/@x}"
            y2="{ dsk:round-and-format(dsk:scale(@start)) }">
        <xsl:apply-templates select="." mode="formatObject"/>
      </line>-->
      
    </xsl:if>
    <!--</xsl:if>-->
    <!--  y="{ dsk:round-and-format(dsk:scale(@start) +
               $spec/dsk:baseline )}"  -->
    <!--<xsl:message>
      <!-\-<xsl:text>At </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text> with </xsl:text>-\->
      <xsl:value-of select="$spec/(@name,'default')[1]"/>
    </xsl:message>-->
    <text x="{ $labelCoords/@x }" y="{ $labelCoords/@y }">
      <xsl:apply-templates  select="." mode="labelFormat"/>
      <xsl:apply-templates  select="." mode="labelText"/>
    </text>
    <xsl:if test="@name='story'">
      <path d="M { $axis } {dsk:round-and-format(dsk:scale(@end)) }
        Q { $axis + 100 }  {dsk:round-and-format(dsk:scale(@end)) }
          { $axis + 120 }  {number(dsk:round-and-format(dsk:scale(@end))) - 5}">
        <xsl:apply-templates select="." mode="formatObject"/>
        <xsl:attribute name="fill">none</xsl:attribute>
      </path>
      <text x="{ $axis + 120 } " y="{number(dsk:round-and-format(dsk:scale(@end))) - 5}">
        <xsl:apply-templates  select="." mode="labelFormat"/>
        <xsl:attribute name="font-size">13</xsl:attribute>
        <xsl:attribute name="text-anchor">start</xsl:attribute>
        <xsl:apply-templates  select="." mode="labelText">
          <xsl:with-param name="ending" select="true()"></xsl:with-param>
        </xsl:apply-templates>
      </text>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="x:range" mode="labelX">
    <xsl:attribute name="x" select="$axis + 10"/>
  </xsl:template>

  <xsl:template match="x:range[@name='letter']" mode="labelX">
    <xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="10000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 2) * 60) + 130 + $axis"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='entry']" mode="labelX">
    <xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="10000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 3) * 35) + 260 + $axis"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='letter'][dsk:covering(.)/@name='letter']" mode="labelX" priority="2">
    <xsl:attribute name="x" select="$axis - 50"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='story']" mode="labelX">
    <xsl:attribute name="x" select="$axis - 100"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='chapter']" mode="labelX">
    <xsl:attribute name="x" select="$axis + 120"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelX">
    <xsl:attribute name="x" select="$axis + 8"/>
  </xsl:template>

  <xsl:template match="x:range[@name='q']" mode="labelX">
    <xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="1000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 2) * 4) + 12 + $axis"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='said']" mode="labelX">
    <xsl:variable name="start" select="number(@start)"/>
    <xsl:variable name="precedents" as="element()*">
      <xsl:apply-templates mode="pullPrecedents" select=".">
        <xsl:with-param name="buffer" tunnel="yes" select="1000"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:attribute name="x" select="(((count($precedents) - 1) mod 10) * 10) + 20 + $axis"/>
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
  
  <xsl:template match="x:range[@name='letter']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">-5</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='chapter']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">-4</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name='p']" mode="labelY">
    <xsl:variable name="baseline" as="xs:double">0.1</xsl:variable>
    <xsl:attribute name="y" select="dsk:round-and-format(dsk:scale(@start) - $baseline )"/>
  </xsl:template>

  <xsl:template match="x:range[@name='said']" mode="labelY">
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
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='letter']">
    <xsl:text>&#xA0;Letter </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content"/>
  </xsl:template>
  
  <xsl:template match="x:range[@name=('head','title')]" mode="labelText">
    <xsl:value-of select="string-join(key('spans-for-rangeID',@ID),'')"/>
  </xsl:template>
    
  <xsl:template mode="labelText" match="x:range[@name='said']">
    <xsl:value-of select="x:annotation[@name='who']/x:content/normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name='titlePage']"/>
  
  <xsl:template mode="labelText" match="x:range[@name='page']">
      <xsl:text>p. </xsl:text>
    <xsl:value-of select="x:annotation[@name='n']/x:content/normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="labelText" match="x:range[@name=('preface','introduction')]">
    <xsl:value-of select="concat(upper-case(substring(@name,1,1)),substring(@name,2))"/>
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
  
  <xsl:function name="dsk:size" as="xs:double">
    <!-- makes lines and scale bolder for larger things, but not linearly -->
    <xsl:param name="extent" as="xs:double"/>
    <xsl:variable name="extent-sqrt">
    <xsl:call-template name="math:sqrt">
      <xsl:with-param name="number" select="$extent"/>
    </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="$extent-sqrt div 500"/>
  </xsl:function>
  
  <xsl:template name="math:sqrt" as="xs:double">
    <!--  The number you want to find the square root of  -->
    <xsl:param name="number"
      select="0" />
    <!--  The current 'try'.  This is used internally.  -->
    <xsl:param name="try"
      select="1" />
    <!--  The current iteration, checked against maxiter to limit loop count  -->
    <xsl:param name="iter"
      select="1" />
    <!--  Set this up to ensure against infinite loops  -->
    <xsl:param name="maxiter"
      select="20" />
    <!--  This template was written by Nate Austin using Sir Isaac Newton's
       method of finding roots  -->
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
  
  <xsl:key name="ranges-for-spanID" match="x:range" use="tokenize(@spans,'\s+')"/>
  
  <xsl:key name="spans-for-rangeID" match="x:span"  use="tokenize(@ranges,'\s+')"/>
  
  <xsl:function name="dsk:covering" as="element(x:range)*">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:sequence select="$r/key('spans-for-rangeID',@ID)/key('ranges-for-spanID',@ID)[dsk:encloses(.,$r)]"/>
  </xsl:function>

  <xsl:function name="dsk:encloses" as="xs:boolean">
    <xsl:param name="r1" as="element(x:range)"/>
    <xsl:param name="r2" as="element(x:range)"/>
    <xsl:sequence select="not($r1 is $r2) and
      ($r1/@start/number() le $r2/@start/number()) and ($r1/@end/number() ge $r2/@end/number())"/>
  </xsl:function>
</xsl:stylesheet>