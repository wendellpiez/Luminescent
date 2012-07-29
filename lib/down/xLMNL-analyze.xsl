<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:z="http://lmnl-markup.org/ns/analysis"
  exclude-result-prefixes="x f xs">

<!-- Analyzes an xLMNL instance for range relations of interest

  -->
  
  <xsl:import href="lmnl-range-operations.xsl"/>
  
  <xsl:strip-space elements="x:document x:range x:annotation"/>

  <xsl:param name="basename" as="xs:string" select="''"/>

  <!-- returns all spans covered by any given range -->
  <xsl:key name="spans-by-rangeID" match="x:span" use="tokenize(@ranges,'\s+')"/>

  <xsl:key name="range-by-ID" match="x:range" use="@ID"/>
  
  <xsl:variable name="all-range-names"
    select="distinct-values(//x:range/@name)"/>

  <xsl:variable name="document"
    select="/x:document"/>

  <xsl:variable name="range-report">
    <!-- raw report in XML format -->
    <xsl:call-template name="report"/>
  </xsl:variable>
  
  <xsl:template match="/">
    <!--<xsl:copy-of select="$range-report/*"/>-->
    <xsl:call-template name="html-output"/>
  </xsl:template>
  
  <xsl:template name="report">
    <z:report>
      <!-- debug: <xsl:for-each select="//x:range">
        <xsl:variable name="here" select="."/>
        <xsl:for-each select="../x:range[f:overlaps(.,$here)]">
          <z:overlaps r1="{$here/@ID}" r2="{@ID}"/>
        </xsl:for-each>
      </xsl:for-each>-->
      
      <xsl:for-each-group select="//x:range" group-by="@name">
        <z:range name="{current-grouping-key()}">
          <xsl:for-each select="current-group()">
            <xsl:variable name="here" select="."/>
            <!--<xsl:for-each-group
              select="../x:range[not(f:excludes(.,$here))]
              [f:overlaps(.,$here)]" group-by="@name">-->
            <xsl:for-each-group group-by="@name"
              select="key('spans-by-rangeID',@ID)/
                      key('range-by-ID',tokenize(@ranges,'\s+'))
                      [f:overlaps(.,$here)]">
              <z:overlap name="{current-grouping-key()}"
                ID="{$here/@ID}"
              cases="{current-group()/@ID}"/>
            </xsl:for-each-group>
          </xsl:for-each>
        </z:range>
      </xsl:for-each-group>
    </z:report>
  </xsl:template>
  
  <xsl:template name="html-output" match="/" mode="html">
    <html>
      <head>
        <!--<title><xsl:text>LMNL range incidence report for </xsl:text>
          <xsl:value-of select="$filename"/>
          </title>-->
        <style type="text/css">

body { font-size: small }

.name { font-size: 120%; font-family: monospace }

h4 { margin: 0em; font-size: 115% }

table { border-collapse: collapse }

th, td { padding: 5px; text-align: center;
  border-radius:2em
 }

th.rowhead { text-align: right }

td.self-overlaps {  background-color: pink }

td.overlaps {  background-color: lavender }

        </style>
        
      </head>
        <body>
        <h4>
          <xsl:text>file: </xsl:text>
          <a href="{$basename}.lmnl">
            <xsl:value-of select="$basename"/>
            <xsl:text>.lmnl</xsl:text>
          </a>
        </h4>
          <!-- do this by identifying spans assigned to disjunct sets of ranges -->
          <xsl:apply-templates select="$range-report/z:report" mode="html"/>
        </body>
    </html>
  </xsl:template>
  
  <xsl:template match="z:report" mode="html">
    <!--<h2>Ranges:</h2>
    <p>
      <!- -<xsl:call-template name="punctuate-series">
        <xsl:with-param name="series">- ->
      <xsl:call-template name="punctuate-sequence">
        <xsl:with-param name="sequence" select="z:range/@name"/>
      </xsl:call-template>
      <!- - </xsl:with-param>
      </xsl:call-template>- ->
    </p>-->
    <div>
    <h2>Overlap relations</h2>
      <table>
        <thead>
          <tr class="header">
            <th>&#xA0;</th>
            <xsl:for-each select="z:range">
              <th>
                <xsl:apply-templates select="@name" mode="name"/>
              </th>
            </xsl:for-each>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="z:range">
            <!--<xsl:sort select="position()" order="descending"/>-->
            <xsl:variable name="checking" select="."/>
            <tr>
              <th class="rowhead">
                <xsl:apply-templates select="@name" mode="name"/>
              </th>
              <xsl:for-each select="../z:range">
                <xsl:variable name="overlaps"
                  select="@name = $checking/z:overlap/@name"/>
                <td class="checked">
                  <!--<xsl:if
                    test="not(preceding-sibling::z:range intersect $checking)">-->
                    <xsl:attribute name="class">
                      <xsl:choose>
                        <xsl:when test="$overlaps and @name=$checking/@name">self-overlaps</xsl:when>
                        <xsl:when test="$overlaps">overlaps</xsl:when>
                        <xsl:otherwise>stacks</xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="$overlaps">
                      <xsl:apply-templates select="$checking/@name" mode="name"/>
                      <xsl:text> | </xsl:text>
                      <xsl:apply-templates select="@name" mode="name"/>
                      <xsl:text> (</xsl:text>
                      <xsl:value-of
                        select="count($checking/z:overlap[@name= current()/@name]/tokenize(@cases,' '))"/>
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                  <!--</xsl:if>-->
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
    <div>
      <h2>Instances of overlap</h2>
      <ul>
      <xsl:for-each select="z:range">
        <xsl:variable name="range-name" select="@name"/>
        <li>
          <xsl:apply-templates select="@name" mode="name"/>
          <xsl:choose>
            <xsl:when test="empty(z:overlap)"> (none)</xsl:when>
            <xsl:otherwise>
              <xsl:text> overlaps:</xsl:text>
              <xsl:for-each select="z:overlap">
                <ul>
                <xsl:value-of select="$range-name"/>
                  <xsl:value-of select="key('range-by-ID',@ID,$document)/z:location(.)"/>
                  <!--<xsl:text>/</xsl:text>
                  <xsl:value-of select="key('range-by-ID',@ID,$document)/(@end - @start)"/>-->
                  <xsl:text> with </xsl:text>
                  <xsl:for-each select="tokenize(@cases,' ')">
                    <xsl:if test="position() gt 1">; </xsl:if>
                    <xsl:value-of select="key('range-by-ID',.,$document)/concat(@name,z:location(.))"/>
                    <!--<xsl:text>/</xsl:text>
                    <xsl:value-of select="key('range-by-ID',.,$document)/(@end - @start)"/>-->
                  </xsl:for-each>
                </ul>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          
        </li>
      </xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  
  <xsl:key name="range-by-ID" match="x:range" use="@ID"/>
  
  <!--<xsl:template name="punctuate-sequence">
    <xsl:param name="sequence" select="()"/>
    <xsl:for-each select="$sequence">
      <xsl:apply-templates mode="name" select="."/>
      <xsl:if test="not(position() eq last())">
      <xsl:text>; </xsl:text>
    </xsl:if>
    </xsl:for-each>
  </xsl:template>-->
  
    
  <xsl:template match="@name" mode="name">
    <span class="name">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>
  
  <xsl:function name="z:location" as="xs:string?">
    <xsl:param name="r" as="element(x:range)"/>
    <xsl:value-of>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="string-join(($r/@sl,$r/@so),'.')"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="string-join(($r/@el,$r/@eo),'.')"/>
      <xsl:text>)</xsl:text>
    </xsl:value-of>
  </xsl:function>
  
</xsl:stylesheet>
