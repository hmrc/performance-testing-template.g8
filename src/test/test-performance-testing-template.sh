#!/bin/bash

# SETUP
start_mongo_container() {
  echo "starting Mongo container"
  if docker ps | grep "mongo"; then
    echo "Mongo container is already running"
  else
    docker run --rm -d --name mongo -p 27017:27017 mongo:3.6
    echo "Mongo container started"
  fi

}

## Services
start_mongo_container
sm --start PLATOPS_EXAMPLE_UI_TESTS -r

# Test 1 - local, cucumber
g8 file://performance-testing-template.g8/ --name=test-1
cd test-1 || exit
# The repository.yml and License file are required for the SbtAutoBuild plugin
cp $WORKSPACE/performance-testing-template.g8/repository.yaml .
cp $WORKSPACE/performance-testing-template.g8/LICENSE .
# A git commit is required for the SbtAutoBuild plugin to work correctly
git init
git add .
git commit -m "Initial commit"
# Run smoke test
sbt -Dperftest.runSmokeTest=true -DrunLocal=true gatling:test
cd - || exit
rm -rf test-1

# TEAR DOWN
sm --stop PLATOPS_EXAMPLE_UI_TESTS
docker stop mongo
