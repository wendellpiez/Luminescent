let $stylesheet := <xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <process>
      <xsl-version>
        <xsl:value-of select="system-property('xsl:version')"/>
      </xsl-version>
    </process>
  </xsl:template>
</xsl:stylesheet>

return

xslt:transform(<dummy/>, $stylesheet )