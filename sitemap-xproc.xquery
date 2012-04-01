declare namespace map = "http://apache.org/cocoon/sitemap/1.0";
declare namespace p = "http://www.w3.org/ns/xproc";

<p:steps> {
let $steps := //map:sitemap/map:pipelines/map:pipeline/map:match[@pattern='**/xLMNL/*.xml']/map:transform
return ( 
for $step in $steps
let $count := count($step/(.|preceding-sibling::map:transform))
return 
<p:output port="step{$count}-{$step/@label}" primary="false">
  <p:pipe port="result" step="{$step/@label}"/>
</p:output>
,
for $step in $steps
return
(<p:identity name="{$step/@label}"/>
,
<p:xslt version="2.0" name="{$step/@label}">
    <p:input port="stylesheet">
      <p:document href="{$step/@src}"/>
    </p:input>
  </p:xslt> )) }
</p:steps>