
(: LUMINESCENT implementation in XQuery 
   July 2013, Wendell Piez (wapiez@wendellpiez.com)
 :)

module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery";
declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

declare option db:chop 'no';

(: Runtime query library for xLMNL :)

declare function lm:return-text($range as element(x:range)) as xs:string? {
  normalize-space(string-join($range/../x:content/x:span[tokenize(@ranges,'\s+') = $range/@ID],''))
};

(: function lm:serialize-lmnl-fragment($spans) returns a LMNL syntax instance
   representing the given spans. These are expected to be contiguous,
   but they don't have to be. They should, however, be on the same layer
   (siblings) or unexpected outputs will result!
 :)
declare function lm:serialize-lmnl-fragment($spans as element(x:span)*) as xs:string {
  if (count($spans/..) gt 1) then '[ERROR: spans not in the same layer]'
  else
     let $lmnl-document := document {
       <x:document>
          <x:content>
           { $spans }
          </x:content>
          { lm:ranges-for-spans($spans) } 
       </x:document> }
   return lm:run-xslt($lmnl-document,lm:xslt-path('../down/xLMNL-write.xsl'),())
};

declare function lm:spans-for-ranges($ranges as element(x:range)*) as element(x:span)* {
     let $rangeIDs := $ranges/@ID
     return $ranges/../x:content/x:span[tokenize(@ranges,'\s+') = $rangeIDs]  
};

declare function lm:ranges-for-spans($spans as element(x:span)*) as element(x:range)* {
     let $rangeIDs := $spans/tokenize(@ranges,'\s+')
     return $spans/../../x:range[@ID = $rangeIDs]  
};

declare function lm:range-value($range as element(x:range)*) as xs:string {
     string-join(lm:spans-for-ranges($range),'')
};


(: Luminescent proper: parsing LMNL syntax into xLMNL :)
declare variable $lm:xslt-dir := "file:///C:/Projects/Github/Luminescent/lib/up";

declare function lm:xslt-path($relative as xs:string) as xs:string
{
  string-join(($lm:xslt-dir,$relative),'/')
};

(: Processes a LMNL syntax instance to generate xLMNL. :)
declare function lm:lmnl-to-xLMNL($lmnl as xs:string,    (: A LMNL document as a string :)
                                  $baseURI as xs:string) (: A Base URI for the xLMNL to note :)
                 as document-node()* {

   let $start := document { <lmnl> { $lmnl } </lmnl> }
   let $params := map { "base-uri" := $baseURI }

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