export OLS4_CONFIG=./config/ols-config/ols-config.json
docker compose down -f -s -v
docker compose up --force-recreate