
module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

declare option db:chop 'false'; 


(: LUMINESCENT implementation in XQuery 
   July 2013, Wendell Piez (wapiez@wendellpiez.com)
 :)


(: Runtime query library for xLMNL :)

(: Function lm:ranges($name,$layer) 
   Returns ranges named $name from layer $layer
   $layer should be either x:document or x:annotation :)
declare function lm:ranges($name as xs:string?, $layer as element()) as element(x:range)* {
  $layer/x:range[lm:named($name,.)]
};

(: Function lm:annotations($name,$range)
   Returns annotations named $name from range $range :)
declare function lm:annotations($name as xs:string?, $range as element(x:range)) as element(x:annotation)* {
  $range/x:annotation[lm:named($name,.)]
};

(: Function lm:named($item,$name)
   Returns boolean true() if range or annotation $item has name $name,
   or is anonymous for $name () (the empty sequence) :)
declare function lm:named($name as xs:string?, $item as element()) as xs:boolean {
  if (exists($name)) then ($item/@name = $name)
  else empty($item/@name)
};

(: Function lm:serialize-lmnl-fragment($spans) returns a LMNL syntax instance
   representing the given spans. These are expected to be contiguous,
   but they don't have to be. They should, however, be on the same layer
   (siblings) or unexpected outputs will result! :)
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

(: Function lm:spans-for-ranges($ranges) retrieves x:span elements covered by (all) ranges in $ranges:)
declare function lm:spans-for-ranges($ranges as element(x:range)*) as element(x:span)* {
     let $spanIDs := $ranges/tokenize(@spans,'\s+')
     return $ranges/../x:content/x:span[@ID = $spanIDs]  
};

declare function lm:ranges-for-spans($spans as element(x:span)*) as element(x:range)* {
     let $rangeIDs := $spans/tokenize(@ranges,'\s+')
     return $spans/../../x:range[@ID = $rangeIDs]  
};

declare function lm:ranges-at-start($start as xs:integer, $layer as element()) as element(x:range)* {
     $layer/x:range[@start = $start]
};

declare function lm:range-value(
                   $ranges as element(x:range)*)
                 as xs:string* {
     $ranges/string-join(lm:spans-for-ranges(.),'')
};

declare function lm:annotation-value(
                   $annotation as element(x:annotation)*)
                 as xs:string* {
     $annotation/x:content/string(.) ! normalize-space(.)};

declare function lm:range-value-ws-trim(
                   $ranges as element(x:range)*)
                 as xs:string* {
     $ranges/lm:range-value(.) ! normalize-space(.)
};

declare function lm:value($item as element()) as xs:string? { 
  (:: for a range, its normalized string value; for
      an annotation, its content as a string:)
  if ($item/self::x:range)      then lm:range-value-ws-trim($item)
  else
  if ($item/self::x:annotation) then lm:annotation-value($item)
  else (name($item))
      
       };

(: Function lm:overlapping-ranges($range) retrieves x:range elements overlapping the range given:)
declare function lm:overlapping-ranges($range as element(x:range)) as element(x:range)* {
     $range/../x:range[lm:range-start(.) lt lm:range-start($range)] (: starts before :)
                      [lm:range-end(.)   lt lm:range-end($range)]   (: ends before :)
                      [lm:range-end(.)   gt lm:range-start($range)] (: ends after start :) |
     $range/../x:range[lm:range-start(.) gt lm:range-start($range)] (: starts after :)
                      [lm:range-end(.)   gt lm:range-end($range)]   (: ends after ::)
                      [lm:range-start(.) lt lm:range-end($range)]   (: starts before end :)
};

(: Function lm:enclosing-ranges($range) retrieves x:range elements named $n, enclosing the -single- range given:)
declare function lm:enclosing-ranges-named($name as xs:string, $range as element(x:range)) as element(x:range)* {
     $range/../x:range[lm:named($name,.)]
                      [lm:range-start(.) le lm:range-start($range)] (: starts with or before :)
                      [lm:range-end(.)   ge lm:range-end($range)]   (: ends with or after :)
     except $range                      
};



declare function lm:range-start($range as element(x:range)) as xs:integer {
 xs:integer($range/@start)
};

declare function lm:range-end($range as element(x:range)) as xs:integer {
 xs:integer($range/@end)
};



(: Luminescent proper: parsing LMNL syntax into xLMNL :)
(:declare variable $lm:xslt-dir := "file:///C:/Users/Wendell/Documents/Github/Luminescent/lib/up";:)

declare variable $lm:xslt-dir := "file:///home/wendell/Documents/Luminescent/lib/up";

(: Processes a LMNL syntax instance to generate xLMNL. :)
declare function lm:lmnl-to-xLMNL($lmnl as xs:string,    (: A LMNL document as a string :)
                                  $baseURI as xs:string) (: A Base URI for the xLMNL to note :)
                 as document-node()* {

   let $start := document { <lmnl> { $lmnl } </lmnl> }
   let $params := map { "base-uri" : $baseURI }

   let $xLMNL-pipeline :=

      (lm:xslt-path('hide-comments.xsl'),
       lm:xslt-path('tokenize.xsl'),
       lm:xslt-path('locate-tokens.xsl'),
       lm:xslt-path('tag-teeth.xsl'),
       lm:xslt-path('assign-types.xsl'),
       lm:xslt-path('label-starts.xsl'),
       lm:xslt-path('label-ends.xsl'),
       lm:xslt-path('infer-annotations.xsl'),
       lm:xslt-path('mark-offsets.xsl'),
       lm:xslt-path('extract-labels.xsl'),
       lm:xslt-path('assign-ids.xsl'),
       lm:xslt-path('mark-spans.xsl'),
       lm:xslt-path('tags-to-xlmnl.xsl'),
       lm:xslt-path('xlmnl-BaseX-optimize.xsl') )    

   return lm:run-xslt-pipeline($start, $xLMNL-pipeline, $params)
};

declare function lm:xLMNL-with-divs($xLMNL as document-node()*,
                                    $elementList as xs:string)
                 as document-node()* {
   let $xslt   := lm:xslt-path('../down/xlmnl-structure.xsl')
   let $params := map { "element-list" : $elementList }
   return lm:run-xslt($xLMNL, $xslt, $params)

};


(: Recursively processes an XSLT pipeline as a sequence of XSLT references (passed in as a list of strings) :)
declare function lm:run-xslt-pipeline($source as document-node(),
                                       $stylesheets as xs:string*,
                                       $params as map(*)? )
                 as document-node() {
   if (empty($stylesheets)) then $source
   else
      let $intermediate := (# db:chop false #) { lm:run-xslt($source, $stylesheets[1], $params) }
      return 
         if (exists($intermediate/EXCEPTION)) then $intermediate
         else (# db:chop false #) { lm:run-xslt-pipeline($intermediate, remove($stylesheets,1),$params) }
};

(: for robustness of execution, to catch Saxon errors and avoid BaseX runtime errors :)
declare function lm:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { (# db:chop false #) { xslt:transform($source, $stylesheet, $params ) } }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};

declare function lm:xslt-path($relative as xs:string) as xs:string
{
  string-join(($lm:xslt-dir,$relative),'/')
};



(: (# db:chop "no"; output:indent "no"; output:format "no" #)  :)
