#!/bin/bash -e

# The script tests performance-testing-template.g8 in CI environment
#
# Prerequisite:
# The script expects the following to be running/installed already:
# - Mongo
# - Service Manager profile for the performance-testing-template.g8. See the README for the SM profile details.
# - Giter8
#
# What does the script do?
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
# - ./test-in-ci.sh
#
# How to run the tests in CI?
# From the project root folder run the script as
# - ./test-in-ci.sh

print() {
  echo
  echo -----------------------------------------------------------------------------------------------------------------
  echo $1
  echo -----------------------------------------------------------------------------------------------------------------
  echo
}

print "INFO: Testing performance-testing-template.g8"

#Creates a sandbox folder to generate test repository
setup_sandbox() {
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

setup_sandbox
generate_repo_from_template
initialize_repo
run_test