xquery version "1.0-ml";
declare option xdmp:mapping "false";

declare variable $OLD-VALUE as xs:string external;

declare variable $URIS :=
  cts:uris(
    (),
	 (),
	 cts:element-value-query(xs:QName("foo"), $OLD-VALUE)
  );

"PROCESS-MODULE.OLD-VALUE=" || $OLD-VALUE,
fn:count($URIS),
$URIS
