
# export OLS4_CONFIG=./config/ols-config/ols-config.json

# export JAVA_OPTS="--add-modules jdk.incubator.vector --add-opens=java.base/java.nio=ALL-UNNAMED -Xms12g -Xmx12g"

# mkdir -p tmp
# sh odk.sh make ontologies -B
# docker compose up ols4-dataload --force-recreate
# docker compose up -d ols4-frontend



#!/usr/bin/env bash
set -euo pipefail

export OLS4_CONFIG=./config/ols-config/ols-config.json
export JAVA_OPTS="--add-modules jdk.incubator.vector --add-opens=java.base/java.nio=ALL-UNNAMED -Xms12g -Xmx12g"

mkdir -p tmp

# Usage:
#   sh runols4.sh           → rebuild all ontologies + reload OLS
#   sh runols4.sh mondo     → rebuild only mondo-edit.owl + reload OLS

if [ "${1:-}" = "mondo" ]; then
  echo ">>> Building mondo-edit.owl only..."
  sh odk.sh make -B ontologies/mondo-edit.owl
else
  echo ">>> Building all ontologies..."
  sh odk.sh make ontologies -B
fi

echo ">>> Reloading OLS dataload..."
docker compose up ols4-dataload --force-recreate

echo ">>> Restarting frontend..."
docker compose up -d ols4-frontend
