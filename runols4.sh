#!/bin/bash
export OLS4_CONFIG=./config/ols-config/ols-config.json
export JAVA_OPTS="--add-modules jdk.incubator.vector --add-opens=java.base/java.nio=ALL-UNNAMED -Xms12g -Xmx12g"

echo "OLS4_CONFIG=$OLS4_CONFIG"
echo "JAVA_OPTS=$JAVA_OPTS"

mkdir -p tmp

# Always stop any existing stack before reload
echo ">>> Stopping any existing OLS containers..."
docker compose down

# Build dataload image (neo4j symlink fix baked in, see Dockerfile.dataload)
echo ">>> Ensuring ols4-dataload image is up to date..."
docker compose build ols4-dataload

# Usage:
#   sh runols4.sh           → rebuild all ontologies + reload OLS
#   sh runols4.sh mondo     → rebuild only mondo-edit.owl + reload OLS
#   sh runols4.sh <target>  → rebuild a specific Makefile target

# Build ontology content to load into OLS
if [ "${1:-}" = "mondo" ]; then
  echo ">>> Building mondo-edit.owl only..."
  sh odk.sh make -B ontologies/mondo-edit.owl
elif [ $# -gt 0 ]; then
  echo ">>> Building target: $*"
  sh odk.sh make -B "$@"
else
  echo ">>> Building all ontologies..."
  sh odk.sh make ontologies -B
fi

# Load the ontology data into neo4j and solr
echo ">>> Reloading OLS dataload..."
docker compose up -d ols4-dataload --force-recreate

# Wait for dataload container to exit successfully
echo ">>> Waiting for dataload to complete..."
docker wait ontotools-docker-ols4-dataload-1

# Only the frontend needs to be restarted due to "depends_on" conditions in docker-compose.yml
# which results in frontend, backend, solr, and neo4j being restarted
echo ">>> Restarting frontend..."
docker compose up -d ols4-frontend

echo ">>> Finished reload"
