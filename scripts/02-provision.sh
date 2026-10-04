#!/usr/bin/env bash
# Uso: SQL_PASSWORD='SenhaForte#123' ./02-provision.sh   (senha NUNCA no código)
set -euo pipefail
: "${SQL_PASSWORD:?Defina SQL_PASSWORD no ambiente}"

SUF=${SUF:-$RANDOM}
RG=rg-dimdim-cp5; LOC=brazilsouth
SQL_SERVER=sql-dimdim-$SUF; SQL_DB=dimdimdb; SQL_USER=dimdimadmin
PLAN=plan-dimdim; APP=app-dimdim-$SUF
LAW=law-dimdim; AI=ai-dimdim; KV=kv-dimdim-$SUF

az group create -n $RG -l $LOC

# Azure SQL (PaaS)
az sql server create -g $RG -n $SQL_SERVER -l $LOC -u $SQL_USER -p "$SQL_PASSWORD"
az sql db create -g $RG -s $SQL_SERVER -n $SQL_DB --service-objective Basic
az sql server firewall-rule create -g $RG -s $SQL_SERVER -n AllowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
MYIP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create -g $RG -s $SQL_SERVER -n MeuIP --start-ip-address $MYIP --end-ip-address $MYIP

# Application Insights (workspace-based)
az monitor log-analytics workspace create -g $RG -n $LAW -l $LOC
az monitor app-insights component create -g $RG -a $AI -l $LOC --workspace $LAW --kind web
AI_CS=$(az monitor app-insights component show -g $RG -a $AI --query connectionString -o tsv)

# Web App Java 21 (Linux)
az appservice plan create -g $RG -n $PLAN -l $LOC --sku B1 --is-linux
az webapp create -g $RG -p $PLAN -n $APP --runtime "JAVA:17-java17"
az webapp identity assign -g $RG -n $APP

# Key Vault: senha do banco como segredo
az keyvault create -g $RG -n $KV -l $LOC --enable-rbac-authorization false
az keyvault secret set --vault-name $KV -n sql-password --value "$SQL_PASSWORD" >/dev/null
PID=$(az webapp identity show -g $RG -n $APP --query principalId -o tsv)
az keyvault set-policy -n $KV --object-id $PID --secret-permissions get list

# App Settings = variáveis de ambiente do Spring. A senha é uma Key Vault reference.
JDBC="jdbc:sqlserver://$SQL_SERVER.database.windows.net:1433;database=$SQL_DB;encrypt=true;trustServerCertificate=false;loginTimeout=30;"
az webapp config appsettings set -g $RG -n $APP --settings \
  "SPRING_DATASOURCE_URL=$JDBC" \
  "SPRING_DATASOURCE_USERNAME=$SQL_USER" \
  "SPRING_DATASOURCE_PASSWORD=@Microsoft.KeyVault(VaultName=$KV;SecretName=sql-password)" \
  "APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CS" \
  "ApplicationInsightsAgent_EXTENSION_VERSION=~3" >/dev/null

echo "APP=$APP  SQL_SERVER=$SQL_SERVER  KV=$KV"
echo "URL: https://$APP.azurewebsites.net"
