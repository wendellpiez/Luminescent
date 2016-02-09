<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master master-name="page"
          page-height="29.7cm"
          page-width="21cm"
          margin-top="1cm"
          margin-bottom="2cm"
          margin-left="2.5cm"
          margin-right="2.5cm">
          <fo:region-before extent="3cm"/>
          <fo:region-body margin-top="3cm"/>
          <fo:region-after extent="1.5cm"/>
        </fo:simple-page-master>

        <fo:page-sequence-master master-name="all">
          <fo:repeatable-page-master-alternatives>
            <fo:conditional-page-master-reference 
             master-reference="page" page-position="first"/>
          </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="all">
        <fo:static-content flow-name="xsl-region-after">
          <fo:block text-align="center"
            font-size="10pt"
            font-family="serif"
            line-height="14pt">page <fo:page-number/></fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
          <fo:block font-size="24pt" space-before.optimum="24pt" 
           text-align="center">XML via XSL-FO</fo:block>
           <xsl:apply-templates select="/content"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
  
  <xsl:template match="content">
    <fo:block font-size="12pt" space-before.optimum="36pt" 
      text-align="center">
    <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="whee">
    <fo:inline font-style="italic">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
  
  
</xsl:stylesheet>