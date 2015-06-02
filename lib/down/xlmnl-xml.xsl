<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://lmnl-markup.org/ns/xLMNL"
  xmlns:f="http://lmnl-markup.org/ns/xslt/utility"
  exclude-result-prefixes="xs f"
  version="2.0">

<!-- Converts xLMNL format into XML
     Accepts an $elements parameter carrying a sequence 
     of strings naming range types to be represented as elements.
     
     (For obvious reasons, anonymous ranges can't be made into elements.)
     
     If $elements is not given or is empty, all ranges are converted.
     
     Annotations on ranges are converted to attributes, with the 
       following limitations:
       1. Annotation content is flattened (no markup is given, any
          annotations on the annotation are lost)
       2. Annotations of the same name are concatenated into
          single attributes
     
     The stylesheet also providesa functions accepting
     x:document or x:annotation element
     and converting them, so its logic may be used by an importing
     stylesheet to generate XML ad-hoc from xLMNL documents or their
     annotations. -->

<!--
  Currently this stylesheet does *not* support namespaces; result
  XML documents are expected to have no namespaces, so range
  and annotation names in the LMNL must be NCnames.
  
  -->
  
  <!--<xsl:output indent="yes"/>-->
  
  <xsl:param name="element-list" as="xs:string*" select="''"/>

  <xsl:key name="range-by-id" match="x:range" use="@ID"/>
  
  <xsl:template match="/">
    <!-- entering from the top, we take $elements from $element-list -->
    <xsl:apply-templates select="x:document">
      <xsl:with-param name="elements" tunnel="yes" as="xs:string*">
        <xsl:choose>
          <xsl:when test="normalize-space($element-list)">
            <!-- we tokenize $element-list if it is given -->
            <xsl:sequence select="tokenize($element-list,'[+\s]+')"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- otherwise we just take everything -->
            <xsl:sequence select="distinct-values(x:range/@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="x:document">
    <!-- creates an XML element with the document or annotation's GI
         (even if it isn't named in the element list) -->
    <xsl:element name="{(@name[f:okay-name(.)],'lmnl-document')[1]}">
      <xsl:copy-of select="namespace::x"/>
      <xsl:call-template name="annotation-attributes"/>
      <xsl:apply-templates select="x:content"/>
    </xsl:element>    
  </xsl:template>
  
  
  <xsl:template match="x:content" name="build-xml">
    <!--<xsl:param name="elements" select="()" tunnel="yes"/>-->
    <xsl:param name="spans" as="element(x:span)*" select="x:span"/>
    <!-- the layer is the lmnl-document or annotation parent -->
    <xsl:param name="layer" tunnel="yes" select=".."/>
    <!-- $elements will be tunneled through -->
    <xsl:variable name="filtered-spans" as="element(x:span)*">
      <xsl:apply-templates select="$spans" mode="filter"/>
    </xsl:variable>
    
    <xsl:call-template name="levitate">
      <xsl:with-param name="layer" tunnel="yes" select="$layer"/>
      <xsl:with-param name="spans" select="$filtered-spans"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="x:span" mode="filter">
    <xsl:param name="elements" select="()" tunnel="yes"/>
    <xsl:variable name="span" select="."/>
    <xsl:variable name="ranges" select="tokenize(@ranges,'\s+')"/>
    <!-- rewrites spans by extracting range identifiers for elements into an @elements attribute -->
    <xsl:copy>
      <xsl:copy-of select="@start | @end"/>
      <!-- $promote names the ranges that will be promoted because they are named among
           $elements (when $elements is empty they will all be) -->
      <xsl:variable name="promote" select="$ranges[f:range-for-span($span,.)/@name = $elements]"/>
      <xsl:attribute name="elements" select="string-join($promote,' ')"/>
      <!--<xsl:if test="exists($ranges[not(.=$promote)])">-->
        <xsl:attribute name="ranges" select="string-join($ranges (: [not(. = $promote)] :),' ')"/>
      <!--</xsl:if>-->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="annotation-attributes">
    <xsl:param name="owner" select="."/>
    <xsl:param name="elements" select="()" tunnel="yes"/>
    <!-- Demotes annotations into XML attributes -->
    <xsl:for-each-group
      select="$owner/x:annotation[empty(x:annotation|x:range)]" group-by="@name">
      <xsl:attribute
        name="{(current-grouping-key()[f:okay-name(.)],'annotation')[1]}">
        <xsl:value-of select="current-group()/x:content/string()" separator=" "
        />
      </xsl:attribute>
    </xsl:for-each-group>
    <xsl:sequence
      select="$owner/x:annotation[exists(x:annotation|x:range)]"
    />
  </xsl:template>
  
  <xsl:template match="x:annotation">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="layer" select="." tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:comment"/>
  
  <xsl:template match="x:annotation/x:content">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:next-match/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="levitate">
    <xsl:param name="layer" as="element()" tunnel="yes"/>
    <xsl:param name="spans" as="element(x:span)*"/>
    <xsl:param name="level" select="1"/>
    <xsl:for-each-group select="$spans" group-adjacent="(tokenize(@elements,'\s+')[$level],'')[1]">
      <xsl:variable name="range" select="key('range-by-id',current-grouping-key(),$layer)"/>
      <xsl:choose>
        <xsl:when test="exists($range)">
          <xsl:call-template name="make-element">
            <xsl:with-param name="range" select="$range"/>
            <xsl:with-param name="contents">
              <xsl:call-template name="levitate">
                <xsl:with-param name="level" select="$level + 1"/>
                <xsl:with-param name="spans" select="current-group()"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <!-- if the grouping string is empty, we're down to text -->
          <xsl:apply-templates select="current-group()" mode="tag"/>
          <!-- we process the current group in tag mode, to write tags for
               ranges we are not promoting -->
        </xsl:otherwise>
      </xsl:choose>
      </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="make-element">
    <xsl:param name="range" required="yes"/>
    <xsl:param name="contents" select="()"/>
    <xsl:element name="{($range/@name[f:okay-name(.)],'e')[1]}">
      <!-- if the range name is no good, we name the element 'e' and
        add a range ID -->
      <xsl:for-each select="$range">
        <xsl:call-template name="annotation-attributes"/>
      </xsl:for-each>
      <xsl:copy-of select="$contents"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*" mode="tag">
    <xsl:copy>
      <xsl:copy-of select="@* except @elements"/>
      <xsl:apply-templates mode="tag"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:span" mode="tag">
    <!-- processing spans in tag mode, we retrieve ranges that start and end with each
         that are not being pulled into the XML, and write tags for them --> 
    <xsl:param name="layer" as="element()" tunnel="yes"/>
    <xsl:variable name="elements" select="key('range-by-id',tokenize(@elements,'\s+'),$layer)/@name"/>
    <xsl:apply-templates mode="start-tag" select="f:range-for-start(@start,$layer)[not(@name=$elements)]">
        <xsl:sort order="descending" data-type="number" select="@end"/>
    </xsl:apply-templates>
    <xsl:copy>
      <xsl:copy-of select="@ranges"/>
      <xsl:apply-templates mode="tag"/>
    </xsl:copy>
    <!-- next come end tags for tags ending after the span -->
    <xsl:apply-templates mode="end-tag"
      select="f:range-for-end(@end,$layer)[not(@name=$elements)]">
      <xsl:sort order="ascending" data-type="number" select="@start"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="x:range" mode="start-tag">
    <x:start name="{@name}" rID="{@ID}">
      <xsl:apply-templates/>
    </x:start>
  </xsl:template>
  
  <xsl:template match="x:range[@start eq @end]" mode="start-tag">
    <xsl:param name="elements" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="@name = $elements">
        <xsl:call-template name="make-element">
          <xsl:with-param name="range" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <x:empty name="{@name}" rID="{@ID}">
          <xsl:apply-templates/>
        </x:empty>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:range" mode="end-tag">
    <x:end name="{@name}" rID="{@ID}"/>
  </xsl:template>
  
  
  <xsl:function name="f:xlmnl-xml" as="document-node()">
    <xsl:param name="layer" as="element(x:document)"/>
    <xsl:param name="elements" as="xs:string*"/>
    <xsl:apply-templates select="$layer">
      <xsl:with-param name="elements" select="$elements" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:function>
  
  <!--<xsl:function name="f:annotation-xml" as="element(x:annotation)">
    <xsl:param name="layer" as="element(x:annotation)"/>
    <xsl:param name="elements" as="xs:string*"/>
    <xsl:for-each select="$layer">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:sequence select="$layer/x:content/preceding-sibling::x:annotation/f:annotation-xml(.,$elements)"/>
        <xsl:apply-templates select="$layer/x:content">
          <xsl:with-param name="elements" select="$elements" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:sequence select="$layer/x:content/following-sibling::x:annotation/f:annotation-xml(.,$elements)"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:function>-->
  
  <xsl:function name="f:spans-xml" as="document-node()">
    <!-- levitates an arbitrary set of spans (expected to be consecutive and
         in the same layer) into XML -->
    <xsl:param name="spans" as="element(x:span)*"/>
    <xsl:param name="elements" as="xs:string*"/>
    <xsl:variable name="layer" select="$spans/ancestor::*[self::x:annotation|self::x:document][1]"/>
    <xsl:choose>
      <xsl:when test="count($layer) eq 1">
        <xsl:call-template name="build-xml">
          <xsl:with-param name="spans" select="$spans"/>
          <xsl:with-param name="elements" select="$elements" tunnel="yes"/>
          <xsl:with-param name="layer" select="$layer" tunnel="yes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Can't build XML from spans given: they are not in the same layer</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="f:range-for-span" as="element(x:range)?">
    <!-- returns a range element given an ID and a layer -->
    <xsl:param name="span" as="element(x:span)"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:sequence select="$span/parent::x:content/../x:range[@ID=$id]"/>
  </xsl:function>
  
  <xsl:function name="f:range-for-start" as="element(x:range)*">
    <!-- returns a range element given a start offset and a layer -->
    <xsl:param name="start" as="xs:integer"/>
    <xsl:param name="layer" as="element()"/>
    <xsl:sequence select="$layer/child::x:range[@start=$start]"/>
  </xsl:function>
  
  <xsl:function name="f:range-for-end" as="element(x:range)*">
    <!-- returns a range element given an ID and a layer -->
    <xsl:param name="end" as="xs:integer"/>
    <xsl:param name="layer" as="element()"/>
    <xsl:sequence select="$layer/child::x:range[@end=$end]"/>
  </xsl:function>
  
  <xsl:function name="f:okay-name" as="xs:boolean">
    <xsl:param name="n" as="xs:string?"/>
    <!-- make this xs:QName when namespaces are supported -->
    <!--<xsl:sequence select="$n castable as xs:NCName"/>-->
    <xsl:sequence select="matches($n,'[\i^:][\c^:]*')"/>
  </xsl:function>

</xsl:stylesheet>