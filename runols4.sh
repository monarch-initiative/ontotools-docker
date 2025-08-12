
export OLS4_CONFIG=./config/ols-config/ols-config.json

export JAVA_OPTS="--add-modules jdk.incubator.vector --add-opens=java.base/java.nio=ALL-UNNAMED -Xms12g -Xmx12g"

mkdir -p tmp
sh odk.sh make ontologies -B
docker compose up ols4-dataload --force-recreate
docker compose up -d ols4-frontend
