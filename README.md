# Corb Test

[CoRB](https://github.com/marklogic-community/corb2) is tool that is commonly used with MarkLogic and it is very powerful.  It has the ability to update your data very quickly.  This also means it has the ability to destroy your data very quickly.  In order to have confidence that your corb job won't ruin your day, you need to test it.

Corb Test is an xquery module to be used in conjunction with [marklogic-unit-test](https://github.com/marklogic-community/marklogic-unit-test) to facilitate testing your corb modules.

How to use Corb Test
1. Add ```corb-test.xqy``` to the equivalent path of marklogic-unit-test, but in your project (```src/test/ml-modules/root/test/```)
2. If your corb modules will not be deployed to normal dev/prd environments (i.e. if you are using [ADHOC modules](https://github.com/marklogic-community/corb2#adhoc-modules)), configure your deployment tool to deploy them to your test environment.
3. Write a test that does the following:
    - import ```corb-test.xqy```
    - exectue ```corb:run-selector``` with the following parameters to test your selector module (this returns asserstions, so return the results)
        -  ```$module-path``` The path to the selector module
        -  ```$module-params``` A map of parameters (declared external variables) for the selector module
        -  ```$included-uris``` URIs that are expected to be returned (does not have to be comprehensive)
        -  ```$excluded-uris``` URIs that are expected not to be returned (it's a good idea to seed your DB with some of these)
        -  ```$additional-param-count``` The number of additional parameters returned from the selector module (passed to the process module) (this is required, and must be correct)
        -  ```$additional-expected-params``` Additional parameters returned from the selector module to verify (optional)
    - In some cases, you may want to execute ```corb:run-selector-and-return-results``` (with the following parameters)
        -  ```$module-path``` The path to the selector module
        -  ```$module-params``` A map of parameters (declared external variables) for the selector module
    - exectue ```corb:run-process``` with the following parameters to test your process module (this returns whatever your process module returns)
        -  ```$module-path``` The path to the process module
        -  ```$module-params``` A map of parameters (declared external variables) for the process module (besides ```$URI```)
        -  ```$uris``` The URIs to run through the process module

Take a look at the example to see Corb Test in action (note that the selector module, process module and test module are all in the example directory; obviously that's not realistic).

Use Corb Test as you see fit.  If your selector simply returns all the URIs in the database, testing it doesn't buy you much.  However, if it executes a complicated query, and you want to be sure it's right, it should be tested.  Corb Test has proved helpful for me on my project, but I'm sure there is room for improvement.  PRs welcome!
