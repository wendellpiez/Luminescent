<?xml version="1.0"?>
<?xml-stylesheet href="processor-version.xsl" type="text/xsl"?>
<!-- ============================================================= -->
<!-- MODULE:    XSL Processor Version Detection Stylesheet         -->
<!--                                                               -->
<!-- MULBERRY INTERNAL VERSION CONTROL:
$Id: processor-version.xsl,v 1.3 2000-05-01 18:52:42-04 tkg Exp $
     ============================================================= -->

<html xsl:version="1.0"
      xmlns:msxsl="http://www.w3.org/TR/WD-xsl"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns="http://www.w3.org/TR/xhtml1/strict">
  <head>
    <title>XSLT Processor Version</title>
  </head>
  <body>
    <xsl:choose>
      <xsl:when test="false()">
        <msxsl:if test=".">
          <p>Vendor: Microsoft
          <br/>Processor version:
            Original IE5 (or old version of other processor)</p>
        </msxsl:if>
      </xsl:when>
      <xsl:otherwise>
        <msxsl:choose>
          <msxsl:when test=".">
          </msxsl:when>
          <msxsl:otherwise>
            <p>Vendor: <xsl:value-of select="system-property('xsl:vendor')"/>
            <br/>Vendor URL:
              <xsl:value-of select="system-property('xsl:vendor-url')"/></p>
          </msxsl:otherwise>
        </msxsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </body>
</html>