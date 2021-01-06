
# performance-testing-template

This repository can be used by teams who are in need of a performance test suite. 

The performance-testing-template.g8 is developed and tested using:
* Java 1.8
* Scala 2.12.11
* sbt 1.3.12
* giter8 0.11.0-M3


## Support
This repository is supported by HMRC Digital's Test Community. If you have a query or find an issue please drop in to the #community-testing channel in Slack.

## Contributions
If you'd like to contribute we welcome you to raise a PR or issue against the project and notify one of the core maintainers in #community-testing.

## Generating a Performance Test project
You **DO NOT** need to clone this project to generate a performance test project from the template. You simply need to have giter8 installed, and run the `g8` command below.

### [Install giter8 CLI](#install-giterate) 
You will need to have giter8 installed in order to generate a test suite from the performance-testing-template. Due to some limitations with the SBT giter8 plugin, unfortunately this template will not generate successfully. 

Instructions to install giter8 can be found [here](http://www.foundweekends.org/giter8/setup.html).

### Generating a Performance Test project from master
To generate a test suite, execute the following command in the parent directory of where you'd like your Performance Test project created:
    
    g8 hmrc/performance-testing-template.g8

This will prompt you for:
- **name** -> The name of the performance test repository.  I.e. my-digital-service-performance-tests

To execute the example tests, follow the steps in the project README.md

### A Note on the Example Requests
The example tests created by this template use the vat-flat-rate-calculator-frontend as an example service.  They are provided to show how to quickly get up and running using the performance testing template. These tests depend on the services in the `PLATFORM_EXAMPLE_UI_TESTS` being available:

    ASSETS_FRONTEND
    KEYSTORE
    CONTACT_FRONTEND
    VAT_FLAT_RATE_CALC_FRONTEND

## Development
To contribute to the performance-testing-template you'll need to test your changes locally before raising a PR (see below).  

### Generating a Performance Test project from you local changes
To create a test project from your local changes, execute the following command from the parent directory of your local copy of the template:

    g8 file://performance-testing-template.g8/ --name=my-test-project

This will create a new performance test project in a folder named `my-test-project/`.  
 
### Running the performance-testing-template.g8 tests
A shell script is available to generate a repository from the template and run a smoke test 
from the newly created repository. Steps to run this script are documented here:
[./test-performance-testing-template.sh](test-performance-testing-template.sh)

**Note:** The script does not include any assertions to ensure that the tests are passing. You will have to consult the 
output to ensure that the tests ran successfully.

#### Testing in CI
In CI, [./test-performance-testing-template.sh](test-performance-testing-template.sh) is used to test the 
performance-testing-template.g8 template in a pipeline via a PR builder before merging changes to master. 

### Scalafmt
The generated template has already been formatted using scalafmt as well as containing a `.scalafmt.conf` configuration and sbt scalafmt plugin ready for teams to use. 

Currently, formatting the files to include in a generated project is a manual task. This involves generating a new template from this project, formatting the generated files and then updating this repository to reflect the new formatting.