import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";
declare option output:separator "\n";

let $doc  := db:open('LMNL-samples','Tempest.xlmnl')

(:
   Distinct values of @who in Frankenstein:
   
   unspecified Byron MWS Walton Mrs. Saville STC ship master Victor lieutenant
   Frankenstein Victor's mother Victor's father Krempe Waldman Clerval
   Dutch schoolmaster Elizabeth Ernest Justine court officer PBS Monster
 :)

(: for $r in ($doc//x:range[@name='q'][x:annotation[@name = 'who'] = 'Krempe']) :)

for $r in ($doc//x:range[@name='sp'][x:annotation[@name = 'speaker'] = 'PROSPERO'])

(: return  '=============&#xA;' || lm:return-text($r) || '&#xA;' :)

return lm:serialize-lmnl-fragment(lm:spans-for-ranges($r))

