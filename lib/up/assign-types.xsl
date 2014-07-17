<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="http://lmnl-markup.org/ns/local"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tokens"
  xmlns="http://lmnl-markup.org/ns/luminescent/tags"
  xpath-default-namespace="http://lmnl-markup.org/ns/luminescent/tags"
  exclude-result-prefixes="xs local s"
  version="2.0">
  
<!-- renames raw tags to assign types:

input:
<tag>[book <tag>[title}</tag>The Book of Job<tag>{title]</tag>
<tag>[version}</tag>KJV<tag>{version]</tag>
<tag>[excerpt}</tag>Chapter One<tag>{excerpt]</tag>]</tag>}</tag>

output:
<start gi="chapter">
  <start gi="book"><start gi="title"/>The Book of Job<end gi="title"/>
    <start gi="version"/>KJV<end gi="version"/>
    <start gi="excerpt"/>Chapter One<end gi="excerpt"/></start></start>

</start>

-->

  <xsl:output indent="no"/>
  
  <xsl:template match="root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="local:type" as="xs:string">
    <xsl:param name="tag" as="element(tag)"/>
    <xsl:variable name="o" select="$tag/s:d[1]"/>
    <xsl:variable name="c" select="$tag/s:d[last()]"/>
    <xsl:choose>
      <xsl:when test="$o = '['">
        <xsl:choose>
          <xsl:when test="$c = '}'">start</xsl:when>
          <xsl:when test="$c = ']'">empty</xsl:when>
          <xsl:otherwise>error</xsl:otherwise>    
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$o = '{'">
        <xsl:choose>
          <xsl:when test="$c = '}'">atom</xsl:when>
          <xsl:when test="$c = ']'">end</xsl:when>
          <xsl:otherwise>error</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>error</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="tag" priority="1">
    <xsl:variable name="o" select="s:d[1]"/>
    <xsl:variable name="c" select="s:d[last()]"/>
    <xsl:element name="{local:type(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="$o/(@l|@o)" mode="locate-start"/>
      <xsl:apply-templates select="$c/(@l|@o)" mode="locate-end"/>
      <xsl:variable name="gi" select="$o/following-sibling::*[1]/self::s:t"/>
      <xsl:if test="boolean($gi)">
        <xsl:attribute name="gi" select="normalize-space($gi)"/>
      </xsl:if>
      <xsl:variable name="contents" select="* except ($o,$gi,$c)"/>
      <xsl:apply-templates select="$contents"/>
      <!--<xsl:if test="not($o is $c) and not(matches($c),'^[\]\}]$'))">
        <error type="UNEXPECTED-VALUE">
          <xsl:value-of select="replace($c,'[\]\}]$','')"/>
        </error>
      </xsl:if>-->
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tag[local:type(.)='error']" priority="2">
    <xsl:variable name="o" select="s:*[1]"/>
    <xsl:variable name="c" select="s:*[last()]"/>
    <error type="UNEXPECTED-TAGGING">
      <xsl:apply-templates select="$o/(@l|@o)" mode="locate-start"/>
      <xsl:apply-templates select="$c/(@l|@o)" mode="locate-end"/>
      <xsl:copy-of select="."/>
    </error>
  </xsl:template>
  
  <xsl:template match="tag[local:type(.)='atom']" priority="2">
    <!-- the outer shell of an atom should not have a name
         i.e. {{atom}} is okay, but {atom{atom}} is not -->
    <xsl:variable name="o" select="s:d[1]"/>
    <xsl:variable name="c" select="s:d[last()]"/>
    <xsl:choose>
      <xsl:when test="empty(node() except ($o,tag[1],$c))
        and exists(tag[local:type(.)='atom'])">
        <!-- a tag delimited { } is okay only if it contains only
              its delimiters plus another tag delimited { } plus -->
        <xsl:apply-templates select="tag" mode="atom"/>
      </xsl:when>
      <xsl:otherwise>
        <error type="UNRECOGNIZED-TAGGING">
          <xsl:apply-templates select="$o/(@l|@o)" mode="locate-start"/>
          <xsl:apply-templates select="$c/(@l|@o)" mode="locate-end"/>
          <xsl:copy-of select="."/>
        </error>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="tag[local:type(.)='atom']" mode="atom">
    <xsl:variable name="o" select="s:d[1]"/>
    <xsl:variable name="c" select="s:d[last()]"/>
    <atom>
      <!-- matching the inner shell of the atom, its properties come
           from the outer shell -->
      <xsl:copy-of select="../@*"/>
      <xsl:apply-templates select="../s:d[1]/(@l|@o)" mode="locate-start"/>
      <xsl:apply-templates select="../s:d[last()]/(@l|@o)" mode="locate-end"/>
      <xsl:variable name="gi" select="$o/following-sibling::*[1]/self::s:t"/>
      <xsl:if test="boolean($gi)">
        <xsl:attribute name="gi" select="normalize-space($gi)"/>
      </xsl:if>
      <xsl:apply-templates select="node() except ($o,$gi,$c)"/>
    </atom>
  </xsl:template>
  
  <xsl:template match="s:d">
    <error code="UNEXPECTED-TAGGING">
      <xsl:apply-templates select="@l|@o" mode="locate-start"/>
      <xsl:apply-templates select="@l|@o" mode="locate-end"/>
      <xsl:apply-templates/>
    </error>
  </xsl:template>
  
  <xsl:template match="s:t">
    <text>
      <xsl:apply-templates/>
    </text>
  </xsl:template>
  
  <xsl:template match="s:comment">
    <comment>
      <xsl:apply-templates select="@l|@o" mode="locate-start"/>
      <xsl:variable name="lines" select="tokenize(.,'\n')"/>
      <xsl:if test="exists(@l | @o)">
        <!-- only generate @el and @eo if we have @l or @o -->
        <xsl:attribute name="el" select="@l + count($lines) - 1"/>
        <xsl:attribute name="eo"
          select="(if (count($lines) gt 1) then 0 else (@o - 1)) + string-length($lines[last()])"/>
      </xsl:if>
      <xsl:value-of select="replace(., '\[!--(.*?)--\]', '$1')"/>
    </comment>
  </xsl:template>
  <!--<xsl:template match="text()[matches(.,'^\s*[\}\]]$')]">
    <error code="UNEXPECTED-TAGGING">
      <xsl:value-of select="."/>
    </error>
  </xsl:template>-->
  
  <xsl:template match="@l" mode="locate-start">
    <xsl:attribute name="sl" select="."/>
  </xsl:template>
  
  <xsl:template match="@o" mode="locate-start">
    <xsl:attribute name="so" select="."/>
  </xsl:template>
  
  <xsl:template match="@l" mode="locate-end">
    <xsl:attribute name="el" select="."/>
  </xsl:template>
  
  <xsl:template match="@o" mode="locate-end">
    <xsl:attribute name="eo" select="."/>
  </xsl:template>
  
  
  
</xsl:stylesheet>