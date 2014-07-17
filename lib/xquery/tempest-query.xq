import module namespace lm = "http://www.lmnl-markup.org/ns/luminescent/xquery" at "luminescent.xqm";

declare namespace x = "http://lmnl-markup.org/ns/xLMNL";

declare option db:chop 'no';
declare option output:separator "\n----\n";

declare function lm:list-speech($speech as element(x:range)) as xs:string {
  $speech/x:annotation[lm:named(.,'speaker')]/x:content/('[' || . || '] ') ||
  lm:list-lines(lm:spans-for-ranges($speech))
};

declare function lm:list-lines($spans as element(x:span)*) as xs:string {
  string-join(
    for $s at $p in $spans
    let $line := lm:ranges-for-spans($s)[lm:named(.,'line')]
    let $emit-lineno := $s is lm:spans-for-ranges($line)[1]

    return
      $line[$emit-lineno]/lm:annotations('n',.)/('[' || x:content || '] ') ||
      lm:ranges-at-start($s/@start,$s/../..)[lm:named(.,'stage')]/lm:list-stagedir(.) ||
      string($s),
      '')
};

declare function lm:list-stagedir($range as element(x:range)) as xs:string {
   let $runin    := false() and exists($range/x:annotation[lm:named(.,'run-in')])
   let $substage := exists($range/../parent::x:range[lm:named(.,'stage')])
   return
    '['[not($runin or $substage)] ||
    $range/lm:annotations((),.)/lm:list-lines(x:content/x:span) ||
    '] '[not($runin or $substage)]
};
let $tempestXLMNL := db:open('LMNL-samples','Tempest.xlmnl')/*

let $speaker      := 'PROSPERO'
let $matchRegex   := '(spirit|sprite)'

let $speechRanges := lm:ranges('sp',$tempestXLMNL)
  [lm:annotations('speaker',.)=$speaker]

for $speech in $speechRanges[matches(lm:range-value(.),$matchRegex,'i')]

return lm:list-speech($speech)

(:

return '[' || $tempestXLMNL/x:content/x:span[1] || ']'
:)