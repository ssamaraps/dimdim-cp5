#!/usr/bin/env bash
# =============================================================================
# Alternativa ao GitHub Actions: build local + az webapp deploy
# Uso: ./04-deploy-manual.sh <nome-do-webapp>
# =============================================================================
set -euo pipefail
APP=${1:?uso: ./04-deploy-manual.sh <nome-do-webapp>}
RG=${RG:-rg-dimdim-cp5-eus}
(cd .. && chmod +x mvnw && ./mvnw -B clean package -DskipTests)
az webapp deploy -g "$RG" -n "$APP" --src-path ../target/dimdim.jar --type jar
echo "Publicado em: https://$APP.azurewebsites.net"
