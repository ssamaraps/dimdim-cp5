#!/usr/bin/env bash
# Gera o Service Principal do pipeline. Copie o JSON para o secret AZURE_CREDENTIALS.
set -euo pipefail
SUB=$(az account show --query id -o tsv)
az ad sp create-for-rbac --name sp-dimdim-gha --role contributor \
  --scopes /subscriptions/$SUB/resourceGroups/rg-dimdim-cp5 --sdk-auth
