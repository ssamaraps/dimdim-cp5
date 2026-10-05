#!/usr/bin/env bash
# =============================================================================
# Gera o Service Principal usado pelo GitHub Actions para publicar no App Service.
# O JSON exibido deve ser colado no secret AZURE_CREDENTIALS do repositório
# (GitHub > Settings > Secrets and variables > Actions). NÃO commitar esse JSON.
#
# Uso: ./03-github-secrets.sh
# =============================================================================
set -euo pipefail
RG=${RG:-rg-dimdim-cp5-eus}
SUB=$(az account show --query id -o tsv)
az ad sp create-for-rbac --name sp-dimdim-gha --role contributor \
  --scopes "/subscriptions/$SUB/resourceGroups/$RG" --sdk-auth
