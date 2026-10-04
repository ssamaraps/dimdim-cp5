#!/usr/bin/env bash
# Alternativa ao GitHub Actions: az webapp deploy
set -euo pipefail
APP=${1:?uso: ./04-deploy-manual.sh <nome-do-webapp>}
(cd .. && ./mvnw -B clean package -DskipTests)
az webapp deploy -g rg-dimdim-cp5 -n $APP --src-path ../target/dimdim.jar --type jar
