import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

let $doc  := db:open('LMNL-samples','Frankenstein.xlmnl')

for $r in ($doc//x:range[@name='q'][x:annotation[@name = 'who'] = 'Monster'])
return lm:return-text($r) || '&#xA;=============&#xA;'

