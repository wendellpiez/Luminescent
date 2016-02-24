

import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

(: declare namespace x = "http://lmnl-markup.org/ns/xLMNL"; :)
declare option output:item-separator "\n=====\n";

let $novel  := db:open('LMNL-library','Frankenstein.xlmnl')/*

(: return $novel/* :)

(: 
//x:range[@name='reflect']/x:annotation[not(@name)]/lm:annotation-value(.)
:)

(:
   Distinct values of @who in Frankenstein:
   
   unspecified Byron MWS Walton Mrs. Saville STC ship master Victor lieutenant
   Frankenstein Victor's mother Victor's father Krempe Waldman Clerval
   Dutch schoolmaster Elizabeth Ernest Justine court officer PBS Monster
 :)

(:return distinct-values(lm:ranges('said',$novel)/lm:annotations('who',.)/lm:annotation-value(.)):)

(: Show all the quotes ('said' ranges) attributed to 'The creature' :)

let $who := 'The creature'

return lm:ranges('said',$novel)[lm:annotations('who',.) = $who] / lm:range-value-ws-trim(.)
 
(: for $narrative in lm:ranges('story',$novel)
let $enclosing-narratives := $narrative/(lm:enclosing-ranges-named('story',.),.)
let $narrator := $narrative/lm:annotations('who',.)/lm:value(.)
group by $narrator
let $speeches := lm:spans-for-ranges($narrative)/lm:ranges-for-spans(.)[lm:named('said',.)]
[empty(lm:enclosing-ranges-named('story',.) except $enclosing-narratives)]

return
<narrative who="{$narrator}" count="{count($speeches)}"> {
  for $who-speeches in $speeches
  let $who := $who-speeches/lm:annotations('who',.)/lm:value(.)
  group by $who
  return <who count="{count($who-speeches)}">{$who}</who> }
<<<<<<< HEAD
=======
 
</narrative> :)
>>>>>>> origin/master
 
</narrative> :)  

(: Find any page with more than 2500 characters (there was one,
   marked erroneously.
return lm:ranges('page',$novel) [ string-length(lm:range-value(.)) gt 2500 ]  /
 ( string-length(lm:range-value(.)) || ':' ||
   x:annotation[lm:named('n',.)]/string(x:content)
 ) :)
 
 
(: distinct-values(lm:ranges('said',$novel)/lm:annotations('who',.)/lm:value(.)) :)
(: distinct-values(lm:ranges('q',$novel)/lm:value(.)):) 

(:for $l in (lm:ranges('letter',$novel))
where $l/preceding-sibling::*:range[@name='letter'][1]/@start >= ($l/@start - 10000)
return $l/@start/string(.):)

(: return lm:ranges('said',$novel)/lm:overlapping-ranges(.)[not(lm:named('page',.))]/@name/string(.) :)



(: Where is 'Paradise' mentioned? (line number and offset) :)

(: return lm:ranges('p',$novel)[matches(lm:range-value(.),'Paradise')] ! string-join((@sl,@so),':') :)

return lm:ranges('page',$novel)[contains(lm:range-value(.),'Volney')]/lm:annotations('n',.)/lm:annotation-value(.)



(: How far in is 'Volney'; where is it located? 
   PUT A FULL TEXT SEARCH OVER DOCUMENTSKETCH FOR FRANKENSTEIN DATA
   DESIGN AN HTML WINDOW ONTO A FORMATTED RENDITION NEXT TO OVAL DIAGRAM 
      TO SLIDE/SCROLL WITH MOUSEOVER ON PAGE SLABS 
:)

(: return lm:serialize-lmnl-fragment(lm:spans-for-ranges($r)) :)

(:
let $allRangeTypes := distinct-values($frankensteinXLMNL/*/x:range/@name)

let $promoteParam := string-join(
   $allRangeTypes[not(.=('page','entry','nar','q'))],
   '+')

:)

(: TEI.2+text+front+titlePage+docTitle+titlePart+docAuthor+epigraph+lg+l+bibl+introduction+head+p+title+soCalled+hi+signed+trailer+preface+body+letter+opener+salute+dateline+lb+chapter+cit+note+term+ref :)

(: return lm:xLMNL-with-divs($frankensteinXLMNL,$promoteParam)


 $promoteParam :)


(: for $quote in lm:ranges('said',$novel)[empty(lm:enclosing-ranges-named('p',.))]
return ($quote/lm:annotations('who',.) || ':: ' || string-join(lm:spans-for-ranges($quote) ! lm:serialize-lmnl-fragment(.),'')) :)