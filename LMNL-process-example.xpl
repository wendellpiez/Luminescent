<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:lmnl="http://lmnl-markup.net/ns/xproc-extensions"
  name="LMNL-wf-check" type="lmnl:LMNL-wf-check">

  <!--<p:output port="raw-svrl" primary="false">
    <p:pipe port="report" step="validate-wf-tagging"/>
  </p:output>-->

  <!--<p:option name="lmnl-file" required="true"/>-->
  
  <p:serialization port="process-result" method="xml"
    indent="true"/>

  <!-- Bind LMNL file to source port using
       -dtext/plain@%LMNLFILE% from command line -->
  <p:input port="source"/>
  
  <p:input kind="parameter" port="parameters" primary="true"/>
  
  <p:output port="process-result" primary="true">
    <p:pipe port="result" step="LMNL-process"/>
  </p:output>

  <p:import href="LMNL-xLMNL.xpl"/>
  
  <lmnl:LMNL-xLMNL name="xLMNL"/>
  
  <p:identity name="LMNL-process"/>
  
  <!--<p:xslt name="LMNL-process" version="2.0">
    <p:input port="stylesheet">
      <p:document href="lib/support/svrl-plaintext.xsl"/>
    </p:input>
  </p:xslt>-->

</p:declare-step>
