Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

docker compose up -d mysql
docker ps --filter name=runk_mysql
