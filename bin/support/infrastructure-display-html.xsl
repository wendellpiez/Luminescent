<xsl:stylesheet version="2.0"
  xmlns:map="http://apache.org/cocoon/sitemap/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">
  
  <xsl:output method="html"/>

   <xsl:template match="/" name='decorate-xml'>
      <html>
         <head>
            <style>
body 
  { font-size:small; font-family: 'Courier New', monospace; margin-right:1.5em;
    background-color:lemonchiffon; whitespace: pre }
div.note { margin: 0.5em; padding:0.5em; background-color:papayawhip; border: thin black dotted }
div.note p { margin-top:0em; margin-bottom:0em }
  .w  {margin-top:1ex; margin-bottom:1ex}
  .e  {margin-left:1em; margin-right:1em}
  .k  {margin-left:1em; margin-right:1em}
  .et  {color:darkred}
  .at  {color:midnightblue}
  .pi  {color:blue}
  .cm  {color:darkgreen; background-color: aliceblue }
  .tx {font-weight:bold}


a { text-decoration: none;
    color: inherit;
    background-color: palegoldenrod }

a:hover { text-decoration: underline }

          </style>
         </head>
      <body class="st">
        <xsl:apply-templates/>
      </body>
      </html>
   </xsl:template>

   <xsl:template match="processing-instruction()">
      <div class="e">
         <span class="pi">
            <xsl:text>&lt;?</xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>?></xsl:text>
         </span>
      </div>
   </xsl:template>

  <xsl:template match="@*">
    <span class="at">
      <xsl:value-of select="concat(' ',name(.))"/>
      <xsl:text>="</xsl:text>
      <xsl:apply-templates select="." mode="attribute"/>
      <xsl:text>"</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="map:transform/@src | xsl:*/@href" mode="attribute">
    <a href="{.}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>
  
  <xsl:template match="text()">
         <span class="tx">
            <xsl:value-of select="."/>
         </span>
   </xsl:template>

   <xsl:template match="comment()">
      <div class="k">
         <span class="cm">
            <xsl:text>&lt;!-- </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text> --></xsl:text>
         </span>
      </div>
   </xsl:template>

  <xsl:template match="*[not(node())]" mode="tag">
    <span class="et">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:apply-templates select="@*"/>
      <xsl:text>/></xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="*" mode="tag">
    <span class="et">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:if test="@*">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="@*"/>
      <xsl:text>></xsl:text>
    </span>
    <xsl:apply-templates/>
    <span class="et">
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>></xsl:text>
    </span>
  </xsl:template>

   <xsl:template match="*">
      <div class="e">
         <xsl:apply-templates select="." mode="tag"/>
      </div>
   </xsl:template>

   <xsl:template match="xsl:stylesheet/node() | map:match">
     <div class="w">
       <xsl:next-match/>
     </div>
   </xsl:template>
  
       
   <xsl:template match="*[text()[normalize-space()]]/*" priority="10">
     <!-- matches elements that appear in mixed content:
          they get no div -->
     <xsl:apply-templates select="." mode="tag"/>
   </xsl:template>
  
</xsl:stylesheet>

