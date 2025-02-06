#!/bin/bash -e

# The script tests performance-testing-template.g8 in CI and local environment
#
# Prerequisite:
# The script expects the following to be installed already:
# - Service Manager
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

log_message() {
  echo
  echo "-----------------------------------------------------------------------------------------------------------------"
  echo "$1"
  echo "-----------------------------------------------------------------------------------------------------------------"
  echo
}

if [[ "$TEST_ENVIRONMENT" == "ci" || "$TEST_ENVIRONMENT" == "local" ]]; then
  log_message "INFO: Testing performance-testing-template.g8 in $TEST_ENVIRONMENT"
else
  log_message "ERROR: TEST_ENVIRONMENT variable is required. Should be one of ci or local"
  exit 1
fi

local_setup() {
  log_message "INFO: Setting up local environment"
  log_message "INFO: Starting Mongo container"
  if docker ps | grep "mongo"; then
    log_message "INFO: Mongo container is already running"
  else
    docker run --rm -d -p 27017:27017 --name mongo mongo:6.0
    log_message "INFO: Mongo container started"
  fi

  log_message "INFO: Starting SM2 profile"
  sm2 --start PLATFORM_TEST_EXAMPLE_UI_JOURNEY_TESTS
}

setup_sandbox() {
  log_message "INFO: Running 'SBT clean' command to clean the target folder"
  sbt clean || exit 1

  TEMPLATE_DIRECTORY=$(pwd)
  SANDBOX="$TEMPLATE_DIRECTORY/target/sandbox"

  log_message "INFO: Creating folder: $SANDBOX"
  mkdir -p "$SANDBOX"
}

generate_repo_from_template() {
  log_message "INFO: Using platform-test-ui-journey-tests-template.g8 to generate new test repository: test-repo."

  TEMPLATE_PATH="file://$TEMPLATE_DIRECTORY"
  REPO_NAME="test-repo"

  log_message "INFO: Changing directory to sandbox: $SANDBOX"
  cd "$SANDBOX" || exit 1

  log_message "INFO: Generating new test repository from Giter8 template..."
  sbt new "$TEMPLATE_PATH" --name="$REPO_NAME"

  log_message "INFO: Test repository created successfully!"
  ls -l "$REPO_NAME"
}

initialise_repo() {
  log_message "INFO: Initialising repository for sbtAutoBuildPlugin with repository.yaml, LICENSE, and an initial git commit"

  cd "$SANDBOX/$REPO_NAME" || exit 1
  cp "$TEMPLATE_DIRECTORY/repository.yaml" .
  cp "$TEMPLATE_DIRECTORY/LICENSE" .

  git init || exit 1
  git add . || exit 1
  git commit -m "Initial commit" || exit 1

  log_message "INFO: Repository successfully initialised."
}

run_test() {
  log_message "INFO: Changing Directory to $SANDBOX/$REPO_NAME"
  cd "$SANDBOX/$REPO_NAME" || exit 1

  log_message "INFO: Test 1 :: STARTING: $REPO_NAME tests"
  sbt -Dperftest.runSmokeTest=true -DrunLocal=true gatling:test
  log_message "INFO: Test 1 :: COMPLETED: $REPO_NAME tests"
}

local_tear_down() {
  log_message "INFO: Tearing down local environment"
  log_message "INFO: Stopping SM profile"
  sm2 --stop PLATFORM_TEST_EXAMPLE_UI_JOURNEY_TESTS

  log_message "INFO: Stopping Mongo container"
  docker stop mongo
}

if [ "$TEST_ENVIRONMENT" = "local" ]; then
  local_setup
fi
setup_sandbox
generate_repo_from_template
initialise_repo
run_test
if [ "$TEST_ENVIRONMENT" = "local" ]; then
  local_tear_down
fi