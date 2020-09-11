**This is a template README.md.  Be sure to update this with project specific content that describes your performance test project.**

# $name$
Performance test suite for the `<digital service name>`, using [performance-test-runner](https://github.com/hmrc/performance-test-runner) under the hood.


## Running the tests

Prior to executing the tests ensure you have:

* Docker - to start mongo container
* Installed/configured service manager

Run the following command to start the services locally:
```
docker run --rm -d --name mongo -d -p 27017:27017 mongo:3.6

sm --start PLATOPS_EXAMPLE_UI_TESTS -r
```

## Logging

The template uses [logback.xml](src/test/resources) to configure log levels. The default log level is *WARN*. This can be updated to use a lower level for example *TRACE* to view the requests sent and responses received during the test.

#### Smoke test

It might be useful to try the journey with one user to check that everything works fine before running the full performance test
```
sbt -Dperftest.runSmokeTest=true -DrunLocal=true gatling:test
```

#### Running the performance test
```
sbt -DrunLocal=true gatling:test
```
### Run the example test against staging environment

#### Smoke test
```
sbt -Dperftest.runSmokeTest=true -DrunLocal=false gatling:test
```

#### Run the performance test

To run a full performance test against staging environment, implement a job builder and run the test **only** from Jenkins.
