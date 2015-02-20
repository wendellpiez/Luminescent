import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";
declare option output:indent "no";
declare option output:format "no";
declare option db:chop 'no';

(: For compiling LMNL into a BaseX db :)

let $lmnldb := 'LMNL-library'

let $silkenTent := '[sonneteer [id}silkentent{id]}[meta [author}Robert Frost{author] [title}A Silken Tent{title]]
[sonnet}
[octave}[quatrain}[line}[s}[phr}She is as in a field a silken tent{line]
[line}At midday when the sunny summer breeze{line]
[line}Has dried the dew and all its ropes relent,{phr]{line]
[line}[phr}So that in guys it gently sways at ease,{phr]{line]{quatrain]
[quatrain}[line}[phr}And its supporting central cedar pole,{phr]{line]
[line}[phr}That is its pinnacle to heavenward{line]
[line}And signifies the sureness of the soul,{phr]{line]
[line}[phr}Seems to owe naught to any single cord,{phr]{line]{quatrain]{octave]
[sestet}[quatrain}[line}[phr}But strictly held by none,{phr] [phr}is loosely bound{line]
[line}By countless silken ties of love and thought{line]
[line}To every thing on earth the compass round,{phr]{line]
[line}[phr}And only by one''s going slightly taut{line]{quatrain]
[couplet}[line}In the capriciousness of summer air{line]
[line}Is of the slightest bondage made aware.{phr]{s]{line]{couplet]{sestet]
{sonnet]{sonneteer]'

(: return lm:lmnl-to-xLMNL('[range [a1}1{] [a2}2{]}testing my range{range [a3}3{a3]]') :)
(: return lm:lmnl-to-xLMNL($silkenTent):)

(: 341000 ms to run - 5 mins 41 sec :)

let $shakespeare-keys := (
  'Ado', 'Ham', 'JC', 'Lr', 'Mac', 'MND', 'MV', 'Oth', 'Rom', 'Shr', 'Tmp', 'TN'
)


(:let $LuminescentPath := 'file:///C:/Users/Wendell/Documents/Github';:)
let $LuminescentPath := 'file:///home/wendell/Documents/Luminescent'


let $shakespeareSet := map:new(
  $shakespeare-keys ! map:entry(
      ('Shakespeare/' || . || '.xlmnl'),
      ($LuminescentPath || '/shakespeare/' || . || '.lmnl') ) )

let $frankensteinSet := map {
   "Frankenstein/1818ed.xlmnl" :=
      $LuminescentPath || '/lmnl/frankenstein1818.lmnl' ,
   "Frankenstein/1831ed.xlmnl" :=
      $LuminescentPath || '/lmnl/frankenstein-as-published.lmnl', 
   "Frankenstein/synoptic.xlmnl"     :=
      $LuminescentPath || '/lmnl/frankenstein.lmnl' }
  
let $fileSet := ($frankensteinSet)  

for $file in map:keys($fileSet)

let $fileURI :=  map:get($fileSet,$file)
let $lmnl    :=  file:read-text($fileURI)

return 
  (db:replace($lmnldb, $file, lm:lmnl-to-xLMNL($lmnl,$fileURI)),
   db:optimize($lmnldb) ) 
  
  (:  lm:lmnl-to-xLMNL($lmnl,$fileURI) :)

(: return map:keys($fileSet) :)
