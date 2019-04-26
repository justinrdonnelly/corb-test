xquery version "1.0-ml";
declare option xdmp:mapping "false";

(: insert 1 doc that should be updated, and one doc that shouldn't :)
declare variable $URI-1 := "/doc/1.xml";
declare variable $DOC-1 :=
  <doc>
    <foo>bar</foo>
  </doc>;
declare variable $URI-2 := "/doc/2.xml";
declare variable $DOC-2 :=
  <doc>
    <foo>bars</foo>
  </doc>;

xdmp:document-insert($URI-1, $DOC-1),
xdmp:document-insert($URI-2, $DOC-2)
; (: transaction separator :)

xquery version "1.0-ml";
import module namespace corb = "com.marklogic.developer.corb" at "/test/corb-test.xqy";
declare option xdmp:mapping "false";

declare variable $CORB-MODULES-DIRECTORY-PATH := "/corb/example/";
declare variable $URI-1 := "/doc/1.xml";
declare variable $URI-2 := "/doc/2.xml";
declare variable $OLD-VALUE := "bar";
declare variable $NEW-VALUE := "baz";
declare variable $PARAMS-MAP := map:entry("OLD-VALUE", $OLD-VALUE);

(: test selector :)
corb:run-selector(
  $CORB-MODULES-DIRECTORY-PATH || "selector.xqy",
  $PARAMS-MAP,
  $URI-1,
  $URI-2,
  1,
  "PROCESS-MODULE.OLD-VALUE=" || $OLD-VALUE
),

(: also run process module so we can test those results too :)
map:put($PARAMS-MAP, "NEW-VALUE", $NEW-VALUE),
corb:run-process(
  $CORB-MODULES-DIRECTORY-PATH || "process.xqy",
  $PARAMS-MAP,
  ($URI-1, $URI-2)
)
; (: transaction separator :)

xquery version "1.0-ml";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare option xdmp:mapping "false";

declare variable $URI-1 := "/doc/1.xml";
declare variable $URI-2 := "/doc/2.xml";

(: confirm $DOC-1 was updated and $DOC-2 was not :)
test:assert-equal(
  text {"baz"},
  fn:doc($URI-1)/doc/foo/text()
),
test:assert-equal(
  text {"bars"},
  fn:doc($URI-2)/doc/foo/text()
),

(: clean up test data :)
xdmp:document-delete($URI-1),
xdmp:document-delete($URI-2)
