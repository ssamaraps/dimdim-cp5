# DimDim – Clientes e Contas na Azure (CP5)

**Grupo:** _<Dimdim>_ | **Integrantes:** _<Samara Porto rm-559072  & Maria Gabriela Landim rm-565146>_
**Vídeo:** _<link>_ | **App:** _https://<app>.azurewebsites.net_

## 1. Descrição da solução
Aplicação web **Java 17 / Spring Boot (MVC + Thymeleaf)** para a DimDim gerenciar **Clientes** e suas **Contas** (N:1), com CRUD completo nas duas tabelas. Dados em **Azure SQL Database (PaaS)**; hospedagem no **Azure App Service (Linux, Java 17)**; monitoramento com **Application Insights**; senha do banco no **Key Vault** (Key Vault reference) e demais configurações em **App Settings**; deploy com **Azure CLI + GitHub Actions**.

## 2. Arquitetura

![Arquitetura da solução](docs/arquitetura.png)

_Usuário → App Service → Azure SQL; App Service → Key Vault (Managed Identity); App Service → Application Insights; GitHub Actions → App Service._

## 3. Estrutura
- `src/` – código-fonte (models, repositories, controllers, templates)
- `scripts/01-create-tables.sql` – DDL · `05-selects-video.sql` – SELECTs de evidência
- `scripts/02-provision.sh` – criação dos recursos via CLI
- `scripts/03-github-secrets.sh` – Service Principal do pipeline
- `scripts/04-deploy-manual.sh` – alternativa `az webapp deploy`
- `.github/workflows/deploy.yml` – pipeline

## 4. How to
1. `az login`
2. Provisionar:
   ```bash
   cd scripts
   export SQL_PASSWORD='SuaSenhaForte#123'
   ./02-provision.sh      # anote APP exibido no final
   ```
3. Portal → SQL Database → **Query editor**: execute `scripts/01-create-tables.sql`.
4. `./03-github-secrets.sh` e copie o JSON.
5. GitHub → Settings → Secrets and variables → Actions:
   - `AZURE_CREDENTIALS` = JSON do passo 4
   - `AZURE_WEBAPP_NAME` = nome do Web App
6. `git push` na `main` → o workflow compila e publica.
7. Acesse `https://<app>.azurewebsites.net`.

**Segredos:** nenhum no repositório. `SPRING_DATASOURCE_*` e a connection string do App Insights ficam em App Settings; a senha do banco é uma referência ao Key Vault.

## 5. Application Insights
Agente Java ativado por App Settings. Portal → `ai-dimdim`: Live Metrics, Transaction search, Failures e Dependencies (chamadas SQL).

## 6. Limpeza
`az group delete -n rg-dimdim-cp5 --yes`
