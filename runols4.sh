export OLS4_CONFIG=./config/ols-config/ols-config.json

mkdir -p tmp
sh odk.sh make ontologies -B
docker compose up ols4-dataload --force-recreate
docker compose up ols4-frontend -d
