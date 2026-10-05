#!/usr/bin/env bash
# =============================================================================
# DimDim CP5 - Provisionamento completo da infraestrutura na Azure (Azure CLI)
#
# Uso (Azure Cloud Shell - Bash):
#   cd scripts
#   chmod +x *.sh
#   ./02-provision.sh
#
# Usuário e senha do banco NÃO ficam no código: o script pede os dois no
# terminal (a senha não aparece na tela) ou lê das variáveis de ambiente
# SQL_USER e SQL_PASSWORD, se já estiverem definidas.
# =============================================================================
set -euo pipefail

# ---------- Credenciais do banco (fora do código-fonte) ----------
if [ -z "${SQL_USER:-}" ]; then
  read -rp  "Usuário administrador do Azure SQL: " SQL_USER
fi
if [ -z "${SQL_PASSWORD:-}" ]; then
  read -rsp "Senha do Azure SQL (não aparece na tela): " SQL_PASSWORD; echo
fi

# ---------- Nomes dos recursos ----------
SUF=${SUF:-$RANDOM}
RG=${RG:-rg-dimdim-cp5}
LOC=${LOC:-brazilsouth}
SQL_SERVER=sql-dimdim-$SUF
SQL_DB=dimdimdb
PLAN=plan-dimdim
APP=app-dimdim-$SUF
LAW=law-dimdim
AI=ai-dimdim
KV=kv-dimdim-$SUF

echo ">> [1/7] Resource Group $RG ($LOC)"
az group create -n "$RG" -l "$LOC" -o table

echo ">> [2/7] Azure SQL Server + Database (PaaS)"
az sql server create -g "$RG" -n "$SQL_SERVER" -l "$LOC" -u "$SQL_USER" -p "$SQL_PASSWORD" -o table
az sql db create -g "$RG" -s "$SQL_SERVER" -n "$SQL_DB" --service-objective Basic -o table
# Libera serviços da Azure (App Service) a acessar o banco
az sql server firewall-rule create -g "$RG" -s "$SQL_SERVER" -n AllowAzure \
  --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 -o table
# Libera o IP de quem está executando (para o Query Editor / testes)
MYIP=$(curl -s https://api.ipify.org || true)
if [ -n "$MYIP" ]; then
  az sql server firewall-rule create -g "$RG" -s "$SQL_SERVER" -n MeuIP \
    --start-ip-address "$MYIP" --end-ip-address "$MYIP" -o table
fi

echo ">> [3/7] Application Insights (workspace-based)"
az monitor log-analytics workspace create -g "$RG" -n "$LAW" -l "$LOC" -o table
az monitor app-insights component create -g "$RG" -a "$AI" -l "$LOC" --workspace "$LAW" --kind web -o table
AI_CS=$(az monitor app-insights component show -g "$RG" -a "$AI" --query connectionString -o tsv)

echo ">> [4/7] App Service Plan + Web App (Linux, Java 17)"
az appservice plan create -g "$RG" -n "$PLAN" -l "$LOC" --sku B1 --is-linux -o table
az webapp create -g "$RG" -p "$PLAN" -n "$APP" --runtime "JAVA:17-java17" -o table

echo ">> [5/7] Managed Identity do Web App"
az webapp identity assign -g "$RG" -n "$APP" -o table
PID=$(az webapp identity show -g "$RG" -n "$APP" --query principalId -o tsv)

echo ">> [6/7] Key Vault + segredo da senha do banco"
az keyvault create -g "$RG" -n "$KV" -l "$LOC" --enable-rbac-authorization false -o table
az keyvault secret set --vault-name "$KV" -n sql-password --value "$SQL_PASSWORD" -o none
az keyvault set-policy -n "$KV" --object-id "$PID" --secret-permissions get list -o none

echo ">> [7/7] App Settings (variáveis de ambiente) - senha via Key Vault reference"
JDBC="jdbc:sqlserver://$SQL_SERVER.database.windows.net:1433;database=$SQL_DB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
az webapp config appsettings set -g "$RG" -n "$APP" --settings \
  "SPRING_DATASOURCE_URL=$JDBC" \
  "SPRING_DATASOURCE_USERNAME=$SQL_USER" \
  "SPRING_DATASOURCE_PASSWORD=@Microsoft.KeyVault(VaultName=$KV;SecretName=sql-password)" \
  "APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CS" \
  "ApplicationInsightsAgent_EXTENSION_VERSION=~3" \
  "XDT_MicrosoftApplicationInsights_Mode=recommended" -o none

unset SQL_PASSWORD

echo ""
echo "=================== RECURSOS CRIADOS ==================="
echo " Resource Group : $RG"
echo " Web App        : $APP"
echo " SQL Server     : $SQL_SERVER.database.windows.net"
echo " Database       : $SQL_DB"
echo " Key Vault      : $KV"
echo " App Insights   : $AI"
echo " URL            : https://$APP.azurewebsites.net"
echo "========================================================"
echo "Próximos passos: criar as tabelas (01-create-tables.sql) e"
echo "configurar o GitHub Actions (03-github-secrets.sh)."
