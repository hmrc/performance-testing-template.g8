#!/bin/bash -e

# The script tests performance-testing-template.g8 in CI and local environment
#
# Prerequisite:
# The script expects the following to be installed already:
# - Service Manager
# - Giter8
#
# What does the script do?
# - When the TEST_ENVIRONMENT variable is set to 'local', the script sets up and tears down the local environment by:
#     - Starting and stopping the mongo container
#     - Starting and stopping the SM profile used by the template for testing.
# - When the TEST_ENVIRONMENT is set to ci the local setup and teardown is ignored.
# - Creates a sandbox folder under target
# - Generates a template from performance-testing-template.g8
# - Runs the performance smoke test against locally running services
#
# When does the test fail in CI?
# When running in CI, Jenkins relies on the exit code from this script to mark the build as failed.
# - When the templated is not created successfully
# - When the performance test returns a failure
#
# How to run the tests locally?
# From the project root folder run the script as
# - ./test-performance-testing-template.sh local
#
# How to run the tests in CI?
# From the project root folder run the script as
# - ./test-performance-testing-template.sh ci

TEST_ENVIRONMENT=$1

print() {
  echo
  echo -----------------------------------------------------------------------------------------------------------------
  echo $1
  echo -----------------------------------------------------------------------------------------------------------------
  echo
}

if [[ "$TEST_ENVIRONMENT" == "ci" || "$TEST_ENVIRONMENT" == "local" ]]; then
  print "INFO: Testing performance-testing-template.g8 in $TEST_ENVIRONMENT"
else
  print "ERROR: TEST_ENVIRONMENT variable is required. Should be one of ci or local"
  exit 1
fi

local_setup() {
  print "INFO: Setting up local environment"
  print "INFO: Starting Mongo container"
  if docker ps | grep "mongo"; then
    print "INFO: Mongo container is already running"
  else
    docker run --rm -d --name mongo -p 27017:27017 mongo:4.0
    print "INFO: Mongo container started"
  fi

  print "INFO: Starting SM profile"
  sm --start PLATFORM_EXAMPLE_UI_TESTS -r --wait 100
}

#Creates a sandbox folder to generate test repository
setup_sandbox() {
  print "INFO: Running 'SBT clean' command to clean the target folder"
  sbt clean

  print "INFO: Setting TEMPLATE_DIRECTORY as $PWD"
  TEMPLATE_DIRECTORY=$PWD
  SANDBOX="$TEMPLATE_DIRECTORY/target/sandbox"
  REPO_NAME="example-performance-test"

  print "INFO: Creating folder: $SANDBOX"
  mkdir -p $SANDBOX
  cd $SANDBOX
}

generate_repo_from_template() {
  print "INFO: Using performance-testing-template.g8 to generate new test repository: $REPO_NAME."
  g8 file:///$TEMPLATE_DIRECTORY --name="$REPO_NAME"
}

#The template uses sbtAutoBuildPlugin which requires repository.yaml, licence.txt and an initial git local commit to compile.
initialize_repo() {
  print "INFO: Initializing repository for sbtAutoBuildPlugin with repository.yaml, licence.txt and an initial git commit"
  cd "$SANDBOX"/"$REPO_NAME"
  cp $TEMPLATE_DIRECTORY/repository.yaml .
  cp $TEMPLATE_DIRECTORY/LICENSE .
  git init
  git add .
  git commit -m "initial commit"
}

run_test() {
  print "INFO: Changing Directory to "$SANDBOX"/"$REPO_NAME""
  cd "$SANDBOX"/"$REPO_NAME"

  print "INFO: Test 1 :: STARTING: $REPO_NAME tests"
  sbt -Dperftest.runSmokeTest=true -DrunLocal=true gatling:test
  print "INFO: Test 1 :: COMPLETED: $REPO_NAME tests"
}

local_tear_down() {
  print "INFO: Tearing down local environment"
  print "INFO: Stopping SM profile"
  sm --stop PLATFORM_EXAMPLE_UI_TESTS

  print "INFO: Stopping Mongo container"
  docker stop mongo
}

if [ "$TEST_ENVIRONMENT" = "local" ]; then
  local_setup
fi
setup_sandbox
generate_repo_from_template
initialize_repo
run_test
if [ "$TEST_ENVIRONMENT" = "local" ]; then
  local_tear_down
fi