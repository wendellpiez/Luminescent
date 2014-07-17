import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";
declare option output:indent "no";
declare option output:format "no";
declare option db:chop 'false';


let $testLMNL := '[test}


  [range=r1}LMNL [range=r2}has{range=r1] ranges{range=r2]   {test]'

return lm:lmnl-to-xLMNL($testLMNL,'test')

(:
let $fileSet := map {
   "Frankenstein.xlmnl" := 'file:///C:/Projects/Github/Luminescent/lmnl/frankenstein.lmnl',
   "Tempest.xlmnl"      := 'file:///C:/Projects/Github/Luminescent/shakespeare/Tmp.lmnl'       }
  
for $file in map:keys($fileSet)
let $fileURI :=  map:get($fileSet,$file)
let $lmnl    := file:read-text($fileURI)

return 
  db:add('LMNL-samples', lm:lmnl-to-xLMNL($lmnl,$fileURI), $file),
  db:optimize('LMNL-samples')
  
  lm:lmnl-to-xLMNL($lmnl,$fileURI) :)
