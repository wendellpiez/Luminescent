import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";
declare option output:item-separator "\n=====\n";

let $novel  := db:open('LMNL-library','Frankenstein.xlmnl')/*

(:
   Distinct values of @who in Frankenstein:
   
   unspecified Byron MWS Walton Mrs. Saville STC ship master Victor lieutenant
   Frankenstein Victor's mother Victor's father Krempe Waldman Clerval
   Dutch schoolmaster Elizabeth Ernest Justine court officer PBS Monster
 :)

(: Show all the quotes ('said' ranges) attributed to 'The creature' :)

(: let $who := 'The creature'

return lm:ranges('said',$novel)[lm:annotations('who',.) = $who] / lm:range-value(.) ! normalize-space(.) :)

(: Find any page with more than 2500 characters (there was one,
   marked erroneously.
return lm:ranges('page',$novel) [ string-length(lm:range-value(.)) gt 2500 ]  /
 ( string-length(lm:range-value(.)) || ':' ||
   x:annotation[lm:named(.,'n')]/string(x:content)
 ) :)
 
return

(: distinct-values(lm:ranges('said',$novel)/lm:annotations('who',.)/lm:value(.)) :)
(: distinct-values(lm:ranges('q',$novel)/lm:value(.)):) 

for $l in (lm:ranges('letter',$novel))
where $l/preceding-sibling::*:range[@name='letter'][1]/@start >= ($l/@start - 10000)
return $l/@start/string(.)


(: Where is Volney mentioned?

return lm:ranges('page',$novel)[contains(lm:range-value(.),'Volney')]

return lm:ranges('p',$novel)[contains(lm:range-value(.),'Volney')]/lm:range-value(.)


 :)

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
