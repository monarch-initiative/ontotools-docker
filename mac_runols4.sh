#!/bin/sh
export OLS4_CONFIG=./config/ols-config/test-ols-config.json
export JAVA_OPTS="--add-modules jdk.incubator.vector --add-opens=java.base/java.nio=ALL-UNNAMED -Xms12g -Xmx12g"

mkdir -p tmp

# Always stop any existing stack before reload
echo ">>> Stopping any existing OLS containers..."
docker compose down -v

# Build dataload image (neo4j symlink fix baked in, see Dockerfile.dataload)
echo ">>> Ensuring ols4-dataload image is up to date..."
docker compose build ols4-dataload

# Change ownership of neo4j if needed
#docker run --rm -v ontotools-docker_ols4-neo4j-data:/data alpine chown -R 7474:7474 /data

# Usage:
#   sh mac_runols4.sh           → rebuild all ontologies + reload OLS
#   sh mac_runols4.sh mondo     → rebuild only mondo-edit.owl + reload OLS
#   sh mac_runols4.sh <target>  → rebuild a specific Makefile target

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

# Run dataload once, stream logs to Terminal
echo ">>> Running OLS dataload..."
docker compose run --rm ols4-dataload

# Change web app URL to localhost
export REACT_APP_APIURL=http://localhost:8080/

# Restart frontend (which also restarts backend, solr, and neo4j) after dataload finishes
echo ">>> Restarting frontend..."
docker compose up -d --build ols4-frontend

# List all loaded ontologies
echo ">>> Waiting for backend until ontologies are loaded..."
until curl -s "http://localhost:8080/api/ontologies" \
  | jq -e '._embedded.ontologies | map(select(.numberOfTerms > 0)) | length > 0' >/dev/null; do
  printf "."
  sleep 5
done
echo ".... done."

# Allow more time for all services to come up
sleep 15

echo ">>> Listing all loaded ontologies..."
curl -s "http://localhost:8080/api/ontologies" \
  | jq -r '._embedded.ontologies[] | [.ontologyId, .loaded, .updated, .version, .config.title, .numberOfTerms] | @tsv'

# Check Solr entity count
echo ">>> Checking Solr entities..."
curl -s "http://localhost:8983/solr/ols4_entities/select?q=*:*&rows=0&wt=json" \
  | jq '.response.numFound'


echo ">>> Finished reload"
