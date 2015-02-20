(:
 : 
 
 To do:
   Wire up db map: db title to BaseX db
   Implement db directory
   SVG XSLT per document via links
   SVG map of document set(s)
 
 :)
module namespace page = 'http://basex.org/modules/web-page';

import module namespace sk = "http://wendellpiez.com/ns/DocSketch" at "../docsketch.xqm";

(: declare default element namespace "http://www.w3.org/1999/xhtml"; :)
declare namespace svg = "http://www.w3.org/2000/svg";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace dhq = "http://www.digitalhumanities.org/ns/dhq";

declare %rest:path("Luminescent")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:luminescent-home() {

  let $title        := 'Luminescent (demonstrations)'
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div>
        <h4><a href="/Luminescent/Frankenstein.html">The case of&#xA0;<i>Frankenstein: or, the Modern Prometheus</i></a></h4>
        {
          ('synoptic','1831ed','1818ed') !
          <h5><a href="/Luminescent/Frankenstein/{.}/graph.svg">{ . } graph (SVG)</a>
          { '&#xa0;' }
          <a href="/Luminescent/Frankenstein/{.}/xlmnl.xml">[xlmnl]</a></h5>
        }
      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
};




declare %rest:path("Luminescent/Frankenstein.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:frankenstein-docsketch-html() as document-node()
{
  let $title        := 'Frankenstein in Luminescent'
  let $doc          := db:open("LMNL-library","Frankenstein/synoptic.xlmnl")
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $html         := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div style="margin-top:1ex; border-top: medium solid black">
        { sk:run-xslt-pipeline($doc,$xsltPipeline,()) }
      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};


declare %rest:path("Luminescent/Frankenstein/{$variant}/graph.svg")
        %output:method("xml")
        %output:media-type("image/svg+xml")
        %output:doctype-public("-//W3C//DTD SVG 1.1//EN")
        %output:doctype-system("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
        %output:omit-xml-declaration("no")
  function page:frankenstein-graph-svg($variant as xs:string) as document-node()
{
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $doc          := db:open("LMNL-library","Frankenstein/" || $variant || ".xlmnl")
  
  return sk:run-xslt-pipeline($doc,$xsltPipeline,())
};

declare %rest:path("Luminescent/Frankenstein/{$variant}/xlmnl.xml")
        %output:method("xml")
        %output:omit-xml-declaration("no")
  function page:frankenstein-xlmnl($variant as xs:string) as document-node() {
     db:open("LMNL-library","Frankenstein/" || $variant || ".xlmnl") };

