import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

declare option db:chop 'no';
(: declare option output:separator "+"; :)
(: declare option output:separator "\n----\n";:)

let $no := false()

let $frankenstein := db:open("LMNL-samples","Frankenstein.xlmnl")
let $elementList := 
( 'TEI.2', 'text',

 

  (  'front', 'titlePage', 'docTitle', 'titlePart', 'docAuthor', 'lb',
     'epigraph', 'lg', 'l', 'bibl',
     'introduction', 'title', 'hi',
     'entry', 'chapter','head',
     'cit', 'note', 'term', 'ref',
     'signed', 'trailer', 'preface',
     'body','letter', 'opener', 'salute', 'dateline',
     'head', 'p','soCalled' )[$no],


  (  'body','letter', 'opener', 'salute', 'dateline',
     'head','nar',
     'q', 'soCalled' )[$no],
    'page')

let $elementRequestParam := string-join(distinct-values($elementList),'+')

let $prettyXSLT := 'file:/C:/Work/Projects/DigitalHumanities/J-TEI/TEI-in-LMNL/lib/frankenstein-filter.xsl'

let $serialization := 
<output:serialization-parameters>
  <output:method value='xml'/>
  <output:indent value='no'/>
</output:serialization-parameters>

return 

lm:xLMNL-with-divs($frankenstein, $elementRequestParam )
  /lm:run-xslt(.,$prettyXSLT,())
  /file:write('file:/C:/Work/Projects/DigitalHumanities/J-TEI/TEI-in-LMNL/JTEI-examples/frankenstein-page-view.xml',.,$serialization)
