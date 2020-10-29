xquery version "1.0-ml";

module namespace corb = "com.marklogic.developer.corb";

import module namespace test = "http://marklogic.com/roxy/test-helper"
  at "/test/test-helper.xqy";

declare namespace t = "http://marklogic.com/roxy/test";

declare option xdmp:mapping "false";

(:~
 : Run the selector (URIS) module and return assertions.
 :
 : @param $module-path The path to the selector module
 : @param $module-params A map of parameters (declared external variables) for the selector module
 : @param $included-uris URIs that are expected to be returned (does not have to be comprehensive)
 : @param $excluded-uris URIs that are expected not to be returned (it's a good idea to seed your DB with some of these)
 : @param $additional-param-count The number of additional parameters returned from the selector module (passed to the process module) (this is required, and must be correct)
 : @param $additional-expected-params Additional parameters returned from the selector module to verify (optional)
 : @return Test assertions
 :)
declare function corb:run-selector(
  $module-path as xs:string,
  $module-params as map:map,
  $included-uris as xs:string*,
  $excluded-uris as xs:string*,
  $additional-param-count as xs:int,
  $additional-expected-params as item()*
) as element(t:result)*
{
  let $results := corb:run-selector-and-return-results(
    $module-path,
    $module-params
  )
  let $uris := fn:subsequence($results, 2 + $additional-param-count) ! xs:string(.) (: drop count of URIs as well as additional parms and convert to strings (corb returns results as strings) :)
  let $count := $results[1 + $additional-param-count]
  let $params := fn:subsequence($results, 1, $additional-param-count)
  return (
    (: count of URIs :)
    test:assert-equal($count, fn:count($uris)),
    (: included URIs (only check that each expected URI is returned, it could also return extras depending on other test data) :)
    for $uri in $included-uris
    return test:assert-at-least-one-equal($uri, $uris),
    (: excluded URIs :)
    for $uri in $excluded-uris
    return test:assert-not-exists(fn:index-of($uris, $uri)),
    (: additional expected params :)
    for $param in $additional-expected-params
    return test:assert-at-least-one-equal($param, $params)
  )
};

(:~
 : Run the process module for a sequence of URIs and return the results.
 :
 : @param $module-path The path to the process module
 : @param $module-params A map of parameters (declared external variables) for the process module (besides $URI)
 : @param $uris The URIs to run through the process module
 : @return The reuslts from the process module
 :)
declare function corb:run-process(
  $module-path as xs:string,
  $module-params as map:map,
  $uris as xs:string*
) as item()*
{
  for $uri in $uris
  return xdmp:invoke(
    $module-path,
    (: DO NOT MUTATE THE ORIGINAL PARAMS MAP :)
    map:new((
      $module-params,
      map:entry("URI", $uri)
    )),
    <options xmlns="xdmp:eval">
      <!--<isolation>same-statement</isolation>-->
      <!-- running in a different transaction allows the client to not have to declare xdmp:transaction-mode "update"-->
      <isolation>different-transaction</isolation>
      <!--<transaction-mode>update-auto-commit</transaction-mode>-->
    </options>
  )
};

(:~
 : Run the selector (URIS) module and return the results (usually don't want to call this directly).
 :
 : @param $module-path The path to the selector module
 : @param $module-params A map of parameters (declared external variables) for the selector module
 : @return The reuslts from the selector module
 :)
declare function corb:run-selector-and-return-results(
  $module-path as xs:string,
  $module-params as map:map
) as item()*
{
  xdmp:invoke(
    $module-path,
    $module-params,
    <options xmlns="xdmp:eval">
      <isolation>same-statement</isolation>
    </options>
  )
};
