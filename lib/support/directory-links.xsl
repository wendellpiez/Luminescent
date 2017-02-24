<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dir="http://apache.org/cocoon/directory/2.0" version="2.0">

  <xsl:param name="dir" select="'testing'"/>

  <!--<xsl:param name="type" select="''"/>-->
  
  <xsl:variable name="demo-dir" select="matches($dir,'^lmnl$')"/>
  <xsl:variable name="sonnet-dir" select="matches($dir,'^sonnets$')"/>
  
  <xsl:variable name="labels" as="element()*">

    <!--<label key="eclix">ECLIX</label>
    <label key="clix">CLIX</label>-->
    <xsl:if test="$sonnet-dir">
      <group>
        <label key="snapshot"/>
      </group>
    </xsl:if>
    
    <xsl:if test="$demo-dir">
      <group name="Luminescent">
        <label key="xLMNL" view="step1">step 1</label>
        <label key="xLMNL" view="step2">step 2</label>
        <label key="xLMNL" view="step3">step 3</label>
        <label key="xLMNL" view="step4">step 4</label>
        <label key="xLMNL" view="step5">step 5</label>
        <label key="xLMNL" view="step6">step 6</label>
        <label key="xLMNL" view="step7">step 7</label>
        <label key="xLMNL" view="step8">step 8</label>
        <label key="xLMNL" view="step9">step 9</label>
        <label key="xLMNL" view="step10">step 10</label>
        <label key="xLMNL" view="step11">step 11</label>
        <label key="xLMNL" view="step12">step 12</label>
      </group>
    </xsl:if>
    
    <group name="Results">
      <label key="xLMNL" color="duskyrose">xLMNL</label>
      <conditional-label key="XML" color="lightsteelblue">XML</conditional-label>
      <label type="-analysis.html" color="skyblue">Analysis</label>
      <conditional-label type="-graph.svg" color="pink">Bubble graph</conditional-label>
      <conditional-label type="-lyric-graph.html" color="pink">Lyric graph</conditional-label>
      <conditional-label type="-map.svg" color="pink">Narrative map (SVG)</conditional-label>
      <conditional-label type="-shakespeare-graph.svg" color="pink">Shakespeare graph</conditional-label>
      <conditional-label type="-voices.html" color="pink">Voices graph</conditional-label>
      <xsl:if test="$dir = 'shakespeare'">
        <!-- come back to ... -->
        <label type="-structured.xml" color="pink">structured XML</label>
        <label type="-display.html" color="pink">display HTML</label>
      </xsl:if>
      <conditional-label type=".html" color="pink">Demo HTML</conditional-label>
      <conditional-label type="-sonneteer.html" color="pink">Sonnet bubbles</conditional-label>
      <conditional-label type="-sonnet-overlap.svg" color="pink">Static B&amp;W sonnet diagram</conditional-label>
    </group>
    <!-- <xsl:choose>
      <xsl:when test="$type='sonnets'">
        <label key="snapshot"/>
        <!-\-<label key="xLMNL" view="structure">Structure</label>
        <label key="xLMNL" view="sentences">Sentences</label>-\->
        <!-\-<label key="xLMNL" view="barsSVG">bars (SVG)</label>-\->
        <label type="-sonnet-arcs.svg">arcs (SVG)</label>
        <label type="-map.svg">map (SVG)</label>
      </xsl:when>
      <xsl:otherwise>
        <label type="-arcs.svg">arcs (SVG)</label>
      </xsl:otherwise>
    </xsl:choose>-->

    <!--<label type=".lmnl">LMNL syntax</label>
    <label key="XMLinduce">XML induction</label>-->

  </xsl:variable>

  <xsl:variable name="lyrics" as="element()+">
    <basename>Easter1916</basename>
    <basename>WinterNight</basename>
    <basename>KublaKhan</basename>
    <basename>Exequy</basename>
    <basename>julian-and-maddalo</basename>
  </xsl:variable>

  <xsl:variable name="page-header">
    <h5>See the <a href="sitemap.html">Cocoon site map</a></h5>
    <xsl:choose>
      <xsl:when test="$dir = 'lmnl'">
        <h5>Other demonstrations: <a href="sonnets">Sonnets</a> | <a href="shakespeare">Shakespeare</a></h5>
        <h1>Luminescent testing miscellany</h1>
        <h3>Various texts below (including complete, fragmentary and factitious examples) demonstrate
        some functionalities supported by the Luminescent LMNL parsing pipeline.</h3>
      </xsl:when>
      <xsl:when test="$dir = 'sonnets'">
        <h5>Other demonstrations: <a href="shakespeare">Shakespeare</a> | <a href="lmnl">Miscellany</a></h5>
        <h1>Sonnets: a structural analysis</h1>
        <p>Two concurrent hierarchies are marked up: the verse form and the grammatical structure
        (as indicated by punctuation of sentences and phrases).</p>
      </xsl:when>
      <xsl:when test="$dir = 'shakespeare'">
        <h5>Other demonstrations: <a href="sonnets">Sonnets</a> | <a href="lmnl">Miscellany</a></h5>
        <h1>Some plays of William Shakespeare, marked up in LMNL syntax</h1>
        <h3>With grateful acknowledgement of the  
          <a href="http://www.folgerdigitaltexts.org/">Folger Digital Texts</a> project,
        from whose XML encoding this LMNL was generated.</h3>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <html>
      <body style="background-color: thistle">
        <xsl:copy-of select="$page-header"/>
        <table>
          <xsl:call-template name="table-header"/>
          <xsl:apply-templates select="//dir:file[ends-with(@name,'lmnl')]"/>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="table-header">
    <tr style="border-top: thin solid black; border-bottom: thin solid black;">
      <td
        style="padding-right: 0.5em; padding-left: 0.5em;border-top: thin solid black;
        background-color:aliceblue">
        <p style="margin:0ex">Source</p>
        <xsl:apply-templates select="$labels" mode="table-header"/></td>
    </tr>
  </xsl:template>
  
  <xsl:template match="group" mode="table-header">
    <td colspan="{count(*)}" style="padding-right: 0.5em; padding-left: 0.5em;
      text-align: center; border-top: thin solid black;
      background-color:{(*/@color,'lavender')[1]}">
      <p style="margin:0ex;font-weight: bold">
        <xsl:apply-templates select="@name"/>
      </p>
    </td>
  </xsl:template>
            
  <xsl:template match="dir:file">
    <xsl:variable name="file" select="normalize-space(@name)"/>
    <tr>
      <td
        style="padding-right: 0.5em; padding-left: 0.5em; background-color: aliceblue">
        <xsl:apply-templates select="../*/meta/(@author, @title)"/>
        <p style="margin:0ex;font-family: monospace; ">
          <a href="{$dir}/{$file}">
            <xsl:value-of select="$file"/>
          </a>
          <xsl:text> [</xsl:text>
          <xsl:value-of select="(round(@size div 100) * 100) div 1000"/>
          <xsl:text>K]</xsl:text>
        </p>
      </td>
      <xsl:apply-templates select="$labels" mode="cell">
        <xsl:with-param name="basename" select="replace($file,'\.lmnl$','')"
          tunnel="yes"/>
      </xsl:apply-templates>
    </tr>
  </xsl:template>

  <xsl:template match="group" mode="cell">
    <xsl:apply-templates mode="cell"/>
  </xsl:template>
  
  <xsl:template match="*" mode="cell" name="cell">
    <td
      style="font-family: sans-serif; font-size: 80%; font-weight: bold;
      background-color:{(@color,'lavender')[1]};
      margin: 6px; padding: 4px">
      <!--<a href="{ (: http://{$host}:8888 :) }/LMNL/{.}/{$dir}/{$file}">-->
      <xsl:apply-templates select="@key|@type" mode="menu-item"/>
    </td>
  </xsl:template>

  <xsl:template match="conditional-label[starts-with(@type,'-voices')]"
    mode="cell">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="matches($basename,'voices')">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[ends-with(@type,'-graph.svg')]" mode="cell">  <!-- only if a stylesheet customized
         for the particular instance can be found -->
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:variable name="xslt"
      select="concat('../down/',$basename,'-graph-svg.xsl')"/>
    <xsl:if test="doc-available(resolve-uri($xslt))">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[.='Narrative map (SVG)']" mode="cell">
    <!-- same for -map.svg -->
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="starts-with($basename,'frankenstein')">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[.='Demo HTML']" mode="cell">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="$basename='demo'">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[.='XML']" mode="cell">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="$dir='sonnets'">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[.='Lyric graph']" mode="cell">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="$basename=$lyrics">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="conditional-label[.='Shakespeare graph']"
    priority="2" mode="cell">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:if test="$dir = 'shakespeare'">
      <xsl:call-template name="cell"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="conditional-label[matches(@type,'sonneteer\.html$|sonnet-overlap.svg$')]"
    mode="cell">
    <xsl:if test="$sonnet-dir">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@author">
    <p style="margin:0ex">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <xsl:template match="@title">
    <p style="margin:0ex; font-style:italic; font-size:90%">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <xsl:template match="@key" mode="menu-item">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:variable name="file" select="concat($basename,'.xml')"/>
    <xsl:variable name="href"
      select="
      concat(
      string-join(($dir,.,$file),'/'),
      for $v in (../@view) return concat('?cocoon-view=',$v))"/>
    <p style="margin:0ex">
      <a href="{$href}">
        <xsl:value-of select=".."/>
      </a>
    </p>
  </xsl:template>

  <xsl:template match="@key[.='snapshot']" mode="menu-item">
    <xsl:param name="basename" tunnel="yes"/>
    <img src="{$dir}/{$basename}-snapshot.png"/>
  </xsl:template>

  <xsl:template match="@key[.='XML']" mode="menu-item">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:variable name="file" select="concat($basename,'.xml')"/>
    <xsl:variable name="basename" select="replace($file,'\.xml$','')"/>
    <p style="margin:0ex">
      <xsl:value-of select=".."/>
      <!--<a href="{$dir}/{$basename}.xml">
        <xsl:value-of select=".."/>
      </a>-->
    </p>

    <xsl:if test="$sonnet-dir">
      <ul style="margin:0ex">
        <li>
          <a href="{$dir}/{$basename}.xml?element-list=sonneteer+sonnet+octave+sestet+quatrain+tercet+couplet+line">Structure</a>
        </li>
        <li>
          <a href="{$dir}/{$basename}.xml?element-list=sonneteer+sonnet+s+phr">Phrasing</a>
        </li>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@type" mode="menu-item">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:variable name="file" select="concat($basename,'.xml')"/>
    <!--<xsl:variable name="basename" select="replace($file,'\.xml$','')"/>-->
    <!--<xsl:variable name="href" select="
      concat(
      string-join(($dir,.,$file),'/'),
      for $v in (../@view) return concat('?cocoon-view=',$v))"/>-->
    <p style="margin:0ex">
      <a href="{$dir}/{$basename}{.}">
        <xsl:value-of select=".."/>
      </a>
    </p>
    <!--<xsl:if test=".='XMLinduce'">
      <ul style="margin:0ex">
      <li><a href="{$href}?stack=sonnet octave sestet quatrain tercet couplet line">Structure</a></li>
      <li><a href="{$href}?stack=s phr">Phrasing</a></li>
      </ul>
      </xsl:if>-->
  </xsl:template>

  <!--
  <xsl:template match="@key[.='snapshot']" mode="menu-item">
    <xsl:param name="basename" tunnel="yes"/>
    <xsl:variable name="file" select="concat($basename,'.xml')"/>
    <img src="{$dir}/{replace($file,'\.xml$','')}-snapshot.png"/>
  </xsl:template>
  -->



</xsl:stylesheet>
