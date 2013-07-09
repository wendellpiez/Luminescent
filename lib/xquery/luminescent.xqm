
(: LUMINESCENT implementation in XQuery 
   July 2013, Wendell Piez (wapiez@wendellpiez.com)
 :)

module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery";
declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

declare option db:chop 'no';

(: Runtime query library for xLMNL :)

declare function lm:return-text($range as element(x:range)) as xs:string? {
  let $id := $range/@ID
  return string-join($range/../x:content/x:span[tokenize(@ranges,'\s+') = $id],'')
};

(: Luminescent proper: parsing LMNL syntax into xLMNL :)
declare variable $lm:xslt-dir := "file:///C:/Projects/Github/Luminescent/lib/up";

declare function lm:xslt-path($relative as xs:string) as xs:string
{
  string-join(($lm:xslt-dir,$relative),'/')
};

(: Processes a LMNL syntax instance to generate xLMNL. :)
declare function lm:lmnl-to-xLMNL($lmnl as xs:string) (: a LMNL document as a string :)
                 as document-node()* {

   let $start := document { <lmnl> { $lmnl } </lmnl> }
   let $params := ()

   let $xLMNL-pipeline :=

      (lm:xslt-path('hide-comments.xsl')     [true()],
       lm:xslt-path('tokenize.xsl')          [true()],
       lm:xslt-path('locate-tokens.xsl')     [true()],
       lm:xslt-path('tag-teeth.xsl')         [true()],
       lm:xslt-path('assign-types.xsl')      [true()],
       lm:xslt-path('label-starts.xsl')      [true()],
       lm:xslt-path('label-ends.xsl')        [true()],
       lm:xslt-path('infer-annotations.xsl') [true()],
       lm:xslt-path('mark-offsets.xsl')      [true()],
       lm:xslt-path('extract-labels.xsl')    [true()],
       lm:xslt-path('assign-ids.xsl')        [true()],
       lm:xslt-path('mark-spans.xsl')        [true()],
       lm:xslt-path('tags-to-xlmnl.xsl')     [true()] )    

   return lm:run-xslt-pipeline($start, $xLMNL-pipeline, $params)
};


(: Recursively processes an XSLT pipeline as a sequence of XSLT references (passed in as a list of strings) :)
declare function lm:run-xslt-pipeline($source as document-node(),
                                       $stylesheets as xs:string*,
                                       $params as map(*)? )
                 as document-node() {
   if (empty($stylesheets)) then $source
   else
      let $intermediate := lm:run-xslt($source, $stylesheets[1], $params)
      return 
         if (exists($intermediate/EXCEPTION)) then $intermediate
         else lm:run-xslt-pipeline($intermediate, remove($stylesheets,1),$params)
};

(: for robustness of execution, to catch Saxon errors and avoid BaseX runtime errors :)
declare function lm:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { (# db:chop "yes"  #) { xslt:transform($source, $stylesheet, $params ) } }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};


(: (# db:chop "no"; output:indent "no"; output:format "no" #)  :)