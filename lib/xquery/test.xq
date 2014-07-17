import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare option output:indent "no";
declare option output:format "no";
declare option db:chop 'no';

let $file := 'file:///C:/Projects/LMNL/Luminescent/lmnl/frankenstein.lmnl'
let $lmnl := file:read-text($file)

return lm:lmnl-to-xLMNL($lmnl,replace($file,'^.+/',''))


