<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://lmnl-markup.org/ns/luminescent/tokens"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- Emits the parameterized input as plain text.
       Gets around an apparent limitation in Cocoon, whereby a 
       reader delivers ISO-8859-1 even when the resource is
       in UTF-8. -->

<!-- Actually, Cocoon works if we do
  
     <map:read mime-type="text/plain;charset=utf-8" src="{1}.lmnl"/>
  
     so this can be used unless EOL normalization is also 
     needed.
  -->
  
  <!-- $plaintext-file should be provided. -->
  <xsl:param name="plaintext-file" as="xs:string*" required="yes"/>
  
  <xsl:template name="start" match="/">
    <xsl:value-of select="s:eol(unparsed-text($plaintext-file,'utf-8'))"/>
  </xsl:template>
   
   <!-- EOL of LF, CR, or CRLF are all normalized to LF (&#xA;) -->
   <xsl:function name="s:eol" as="xs:string?">
     <xsl:param name="in" as="xs:string?"/>
     <xsl:sequence select="replace($in,'&#xA;|(&#xD;&#xA;?)','&#xA;')"/>
   </xsl:function>

</xsl:stylesheet>