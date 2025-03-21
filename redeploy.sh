#!/bin/bash

set -e
SECONDS=0
ODK=obolibrary/odkfull:v1.5.4

export OLS4_CONFIG=./config/ols-config/ols-config.json

mkdir -p tmp ontologies

##############################################
############ Pipeline ########################
##############################################

# pre-step: run 'make ontologies' using the ODK image
docker run \
  -v $PWD:/work -w /work \
  -e ROBOT_JAVA_ARGS='-Xmx16G' \
  -e JAVA_OPTS='-Xmx16G' \
  --rm -ti \
  ${ODK} make ontologies -B

echo "INFO: Running dataload ($SECONDS seconds).."
docker compose up ols4-dataload --force-recreate

echo "INFO: Starting frontend ($SECONDS seconds).."
docker compose up ols4-frontend

echo "INFO: Redeploying Custom OLS pipeline completed in $SECONDS seconds!"
