<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:lmnl="http://lmnl-markup.net/ns/xproc-extensions"
  name="LMNL-xLMNL" type="lmnl:LMNL-xLMNL">

  <p:input port="source"/>  

  <!--<p:option name="lmnl-file" required="true"/>-->

  <p:input kind="parameter" port="parameters" primary="true"/>
  
  <p:serialization port="step0-comment" indent="true" encoding="utf-8"/>
  <p:output port="step0-comment" primary="false">
    <p:pipe port="result" step="comment"/>
  </p:output>
  
  <p:serialization port="step1-tokenize" indent="true" encoding="utf-8"/>  
  <p:output port="step1-tokenize" primary="false">
    <p:pipe port="result" step="tokenize"/>
  </p:output>
  
  <p:serialization port="step2-locate-tokens" indent="true"/>
  <p:output port="step2-locate-tokens" primary="false">
    <p:pipe port="result" step="locate-tokens"/>
  </p:output>
  
  <p:serialization port="step3-tag-sawteeth" indent="true" encoding="utf-8"/>
  <p:output port="step3-tag-sawteeth" primary="false">
    <p:pipe port="result" step="tag-sawteeth"/>
  </p:output>
  
  <p:serialization port="step4-assign-types" indent="true" encoding="utf-8"/>
  <p:output port="step4-assign-types" primary="false">
    <p:pipe port="result" step="assign-types"/>
  </p:output>
  
  <p:serialization port="step5-label-starts" indent="true" encoding="utf-8"/>
  <p:output port="step5-label-starts" primary="false">
    <p:pipe port="result" step="label-starts"/>
  </p:output>

  <p:serialization port="step6-label-ends" indent="true" encoding="utf-8"/>
  <p:output port="step6-label-ends" primary="false">
    <p:pipe port="result" step="label-ends"/>
  </p:output>

  <p:serialization port="step7-infer-annotations" indent="true" encoding="utf-8"/>
  <p:output port="step7-infer-annotations" primary="false">
    <p:pipe port="result" step="infer-annotations"/>
  </p:output>

  <p:serialization port="step8-mark-offsets" indent="true" encoding="utf-8"/>
  <p:output port="step8-mark-offsets" primary="false">
    <p:pipe port="result" step="mark-offsets"/>
  </p:output>

  <p:serialization port="step9-extract-labels" indent="true" encoding="utf-8"/>
  <p:output port="step9-extract-labels" primary="false">
    <p:pipe port="result" step="extract-labels"/>
  </p:output>

  <p:serialization port="step10-assign-ids" indent="true" encoding="utf-8"/>
  <p:output port="step10-assign-ids" primary="false">
    <p:pipe port="result" step="assign-ids"/>
  </p:output>

  <p:serialization port="step11-mark-spans" indent="true" encoding="utf-8"/>
  <p:output port="step11-mark-spans" primary="false">
    <p:pipe port="result" step="mark-spans"/>
  </p:output>

  <p:serialization port="step12-tags-to-xlmnl" indent="true" encoding="utf-8"/>
  <p:output port="step12-tags-to-xlmnl" primary="true">
    <p:pipe port="result" step="tags-to-xlmnl"/>
  </p:output>

  
  <!--<p:identity name="comment"/>-->
  <p:xslt name="comment" version="2.0">
    <!--<p:input port="source">
      <p:inline><lmnl><!-\- dummy document -\-></lmnl></p:inline>
    </p:input>-->
    <p:input port="stylesheet">
      <p:document href="lib/up/hide-comments.xsl"/>
    </p:input>
    <!--<p:with-param name="lmnl-file" select="$lmnl-file"/>-->
  </p:xslt>
  
  <!--<p:identity name="tokenize"/>-->
  <p:xslt name="tokenize" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/tokenize.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="locate-tokens"/>-->
  <p:xslt name="locate-tokens" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/locate-tokens.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="tag-sawteeth"/>-->
  <p:xslt name="tag-sawteeth" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/tag-teeth.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:validate-with-schematron assert-valid="false"
    name="validate-tags">
    <p:input port="schema">
      <p:document href="lib/wf-check/validate-tags.sch"/>
    </p:input>
  </p:validate-with-schematron>-->
  
  <!--<p:identity name="assign-types"/>-->
  <p:xslt name="assign-types" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/assign-types.xsl"/>
    </p:input>
  </p:xslt>

  
  <!--<p:identity name="label-starts"/>-->
  <p:xslt name="label-starts" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/label-starts.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="label-ends"/>-->
  <p:xslt name="label-ends" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/label-ends.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="infer-annotations"/>-->
  <p:xslt name="infer-annotations" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/infer-annotations.xsl"/>
    </p:input>
  </p:xslt>

  <!--<p:identity name="mark-offsets"/>-->
  <p:xslt name="mark-offsets" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/mark-offsets.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="extract-labels"/>-->
  <p:xslt name="extract-labels" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/extract-labels.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="assign-ids"/>-->
  <p:xslt name="assign-ids" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/assign-ids.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="mark-spans"/>-->
  <p:xslt name="mark-spans" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/mark-spans.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="tags-to-xlmnl"/>-->
  <p:xslt name="tags-to-xlmnl" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/up/tags-to-xlmnl.xsl"/>
    </p:input>
  </p:xslt>


</p:declare-step>
