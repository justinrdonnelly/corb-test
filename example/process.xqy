xquery version "1.0-ml";
declare option xdmp:mapping "false";

declare variable $URI as xs:string external;
declare variable $OLD-VALUE as xs:string external;
declare variable $NEW-VALUE as xs:string external;

let $doc := fn:doc($URI)
let $foo-text := $doc/doc/foo/text()
where $foo-text eq $OLD-VALUE (: confirm this doc hasn't already been updated by some other means :)
return xdmp:node-replace($foo-text, text {$NEW-VALUE})
