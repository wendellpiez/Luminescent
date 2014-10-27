<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://lmnl-markup.org/ns/luminescent/tokens"
  xmlns:local="http://lmnl-markup.org/ns/local"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- Recognizes and tags with 'token' markup delimiters
       in LMNL "sawtooth" syntax -->

  <!-- input example:

[zoo}
[empty [e}1{e] [test}TEST ME{]]
[excerpt [source}The [n=n1}Housekeeper{source] [author}Robert Frost{author]}
...

       output example:

<s:root xmlns:s="http://lmnl-markup.org/ns/luminescent/tokens"><s:d>[</s:d><s:t>zoo</s:t><s:d>}</s:d><s:t>
</s:t><s:d>[</s:d><s:t>empty </s:t><s:d>[</s:d><s:t>e</s:t><s:d>}</s:d><s:t>1</s:t><s:d>{</s:d><s:t>e</s:t><s:d>]</s:d><s:t> </s:t><s:d>[</s:d><s:t>test</s:t><s:d>}</s:d><s:t>TEST ME</s:t><s:d>{</s:d><s:d>]</s:d><s:d>]</s:d><s:t>
</s:t><s:d>[</s:d><s:t>excerpt </s:t><s:d>[</s:d><s:t>source</s:t><s:d>}</s:d><s:t>The </s:t><s:d>[</s:d><s:t>n=n1</s:t><s:d>}</s:d><s:t>Housekeeper</s:t><s:d>{</s:d><s:t>source</s:t><s:d>]</s:d><s:t> </s:t><s:d>[</s:d><s:t>author</s:t><s:d>}</s:d><s:t>Robert Frost</s:t><s:d>{</s:d><s:t>author</s:t><s:d>]</s:d><s:d>}</s:d><s:t>
...
       -->

  <!-- If $lmnl-file is provided, it is read as plain text. Otherwise,
       the data value of the input document is read. -->
  <xsl:param name="lmnl-file" as="xs:string*"/>
  
  <xsl:variable name="source">
    <xsl:choose>
      <xsl:when test="normalize-space($lmnl-file)">
        <xsl:sequence select="unparsed-text($lmnl-file)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="/string()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template name="start" match="t:root">
    <t:root>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="delimiters" as="xs:string">\[\]{}</xsl:variable>
      <xsl:analyze-string select="$source" regex="[{$delimiters}]">
        <xsl:matching-substring>
          <t:d>
            <xsl:value-of select="local:eol(.)"/>
          </t:d>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <t:t>
            <xsl:value-of select="local:eol(.)"/>
          </t:t>   
        </xsl:non-matching-substring>
      </xsl:analyze-string>
      </t:root>
  </xsl:template>
   
   <!-- EOL of LF, CR, or CRLF are all normalized to LF (&#xA;) -->
   <xsl:function name="local:eol" as="xs:string?">
     <xsl:param name="in" as="xs:string?"/>
     <xsl:sequence select="replace($in,'&#xA;|(&#xD;&#xA;?)','&#xA;')"/>
   </xsl:function>

</xsl:stylesheet>