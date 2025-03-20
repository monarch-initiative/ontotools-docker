export OLS4_CONFIG=./config/ols-config/ols-config.json
mkdir -p tmp
#docker compose rm -f -v
#docker compose up ols4-dataload --force-recreate
docker compose up --force-recreate