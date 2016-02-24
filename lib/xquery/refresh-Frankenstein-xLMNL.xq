import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";
declare option output:indent "no";
(: declare option output:format "no"; :)
declare option db:chop 'no';

(: For compiling LMNL into a BaseX db :)

let $lmnldb := 'LMNL-library'

(:let $LuminescentPath := 'file:///C:/Users/Wendell/Documents/Github';:)
let $LuminescentPath := 'file:///home/wendell/Documents/Luminescent'

let $filePath := $LuminescentPath || '/lmnl/frankenstein.lmnl'
let $dbPath   := 'Frankenstein/synoptic.xlmnl'

let $lmnl    :=  file:read-text($filePath)

return 
  (db:replace($lmnldb, $dbPath, lm:lmnl-to-xLMNL($lmnl,$filePath)),
   db:optimize($lmnldb) ) 
  
  (:  lm:lmnl-to-xLMNL($lmnl,$fileURI) :)

(: return map:keys($fileSet) :)
