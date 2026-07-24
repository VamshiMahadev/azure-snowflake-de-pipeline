# Azure & Snowflake Medallion Data Engineering Platform

An automated end-to-end cloud data pipeline built using **Terraform (Infrastructure as Code)**, **Azure Blob Storage**, **Snowflake Data Warehouse**, **Python**, and **GitHub Actions**.

## Highlights

- Infrastructure as Code
- Azure + Snowflake Integration
- CDC Automation
- GitHub Actions CI/CD
- Medallion Architecture
- Enterprise Healthcare Use-case Simulation

## Future Enhancements

- Delta Loads
- Data Quality Framework
- SCD Type 2 Implementation
- Data Observability
- Unit Testing
- Monitoring & Alerting
---

## 🏥 Domain & Healthcare Relevance: Quality & Global Complaints Engineering

This data platform architecture mimics enterprise healthcare and medical device management systems such as **Fresenius Medical Care**, **TrackWise**, and **Global Quality Management (GMQ)** platforms.

### Healthcare Wing Alignment

- **Quality Assurance & Regulatory Compliance**: Pharmacovigilance and Device Safety monitoring.
- **Global Complaints Management**: Processing incoming customer, clinical, and patient incident complaints related to medical equipment, dialysis machines, or pharmaceuticals.
- **Auditability & Traceability**: Immutable raw payload storage landing in Azure Blob Storage with Change Data Capture (CDC) processing inside Snowflake.
- **Regulatory Alignment**: Designed to align with health authority auditability guidelines, such as **FDA 21 CFR Part 11** and **EMA regulations**.

---

## 🏗️ Architecture Overview

```text
                    GitHub Actions CI/CD
                              |
               --------------------------------
               |                              |
               |                              |
               ▼                              ▼
        Pipeline 01                        Pipeline 02
       (Azure Infra)                (Snowflake & Ingestion)
               |                              |
        Terraform Deploy                Python Ingestion
               |                        + SQL Automation
               |                        + CDC Processing
               |                              |
               ▼                              ▼
      Azure Resource Group              Open REST APIs
               |                              |
               ▼                              |
        Azure Blob Storage <-------------------
         Container: raw-data
               |
               | (External Stage + SAS Token)
               |
               ▼
     ------------------------------------------------
                    Snowflake Medallion Layer
     ------------------------------------------------

                    BRONZE_RAW
                  RAW_BREWERIES
                    (VARIANT)

                        |
                   CDC STREAM
                        |
                        ▼

                  SILVER_STAGING
                  DIM_BREWERIES
                 (Relational Model)

                        |
                   CHAINED TASK
                        |
                        ▼

                  GOLD_ANALYTICS
         FACT_BREWERY_SUMMARY_BY_STATE

     ------------------------------------------------
```

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── 01-azure-infra.yaml
│       └── 02-snowflake-ingest.yaml
├── scripts/
│   ├── fetch_and_load.py
│   └── run_snowflake_setup.py
├── snowflake/
│   ├── 01_rbac_and_infra.sql
│   ├── 02_azure_integration.sql
│   ├── 03_bronze_ingestion.sql
│   ├── 04_transformations.sql
│   └── 05_cdc_automation.sql
└── terraform/
    ├── main.tf
    ├── snowflake.tf
    └── variables.tf
```

## 📄 File Descriptions

| File | Purpose |
|------|---------|
| 01-azure-infra.yaml | Deploys Azure storage infrastructure using Terraform |
| 02-snowflake-ingest.yaml | Executes dynamic SAS token generation, Snowflake DDL setup, and Python ingestion |
| fetch_and_load.py | Extracts REST API data and loads it into Azure Blob Storage and Snowflake |
| run_snowflake_setup.py | Executes multiple Snowflake SQL scripts sequentially |
| 01_rbac_and_infra.sql | Creates roles, warehouses, databases, and grants EXECUTE TASK |
| 02_azure_integration.sql | Configures stages and file formats using dynamic SAS token interpolation |
| 03_bronze_ingestion.sql | Creates Bronze ingestion landing tables and external tables |
| 04_transformations.sql | Creates Silver relational dimensions and Gold analytical views |
| 05_cdc_automation.sql | Creates Streams, Tasks, and CDC automated execution DAGs |
| main.tf | Defines Azure storage resources via Terraform |
| snowflake.tf | Defines Snowflake provider configuration |
| variables.tf | Stores Terraform input variables |

## 🔐 Required GitHub Secrets Setup

Add the following repository secrets:

| Secret Name | Description |
|------------|------------|
| AZURE_CLIENT_ID | Azure Service Principal Application ID |
| AZURE_CLIENT_SECRET | Azure Service Principal Client Secret |
| AZURE_TENANT_ID | Microsoft Entra Tenant ID |
| AZURE_SUBSCRIPTION_ID | Azure Subscription ID |
| AZURE_RESOURCE_GROUP | Azure Resource Group Name |
| AZURE_LOCATION | Deployment Region |
| SNOWFLAKE_ACCOUNT | Snowflake Account Identifier |
| SNOWFLAKE_USER | Snowflake Admin Username |
| SNOWFLAKE_PASSWORD | Snowflake Account Password |

## 🚀 Execution & Setup Guide

### Step 1: Clone & Push Repository

```bash
git clone https://github.com/VamshiMahadev/azure-snowflake-de-pipeline.git
cd azure-snowflake-de-pipeline

git branch -M main
git add .
git commit -m "feat: setup azure and snowflake pipeline"
git push -u origin main
```

### Step 2: Deploy Azure Infrastructure Pipeline

Run the `01 - Azure Infrastructure Pipeline` workflow from GitHub Actions.

Pipeline tasks:
- Authenticates into Azure using Service Principal.
- Deploys or validates the Resource Group via Terraform.
- Provisions Storage Account and `raw-data` Blob container.

### Step 3: Execute Snowflake Setup & Ingestion Pipeline

Run the `02 - Snowflake DB & Ingestion Pipeline` workflow from GitHub Actions.

Pipeline tasks:
- Retrieves Azure Storage Account details dynamically via Azure CLI.
- Generates a secure, 7-day container SAS token.
- Creates Snowflake databases, schemas, stages, streams, and tasks.
- Pulls API data and uploads JSON files into Azure Blob Storage.
- Issues `COPY INTO` commands for ingestion.
- Automatically triggers CDC Streams and Task DAGs for Silver and Gold layer processing.

## 🧪 Pipeline Validation

```sql
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;

SELECT 'BRONZE' AS LAYER, COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES
UNION ALL
SELECT 'SILVER' AS LAYER, COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.SILVER_STAGING.DIM_BREWERIES
UNION ALL
SELECT 'GOLD' AS LAYER, COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.GOLD_ANALYTICS.FACT_BREWERY_SUMMARY_BY_STATE;
```

### Expected Output

```text
+---------+------------+
| LAYER   | ROW_COUNT  |
+---------+------------+
| BRONZE  |     50     |
| SILVER  |     50     |
| GOLD    |     32     |
+---------+------------+
```

## 🛠️ Technologies Used

- Cloud Platform: Azure Blob Storage and Microsoft Entra ID
- Infrastructure as Code (IaC): Terraform
- Data Warehouse: Snowflake
- Data Ingestion: Python (`azure-storage-blob`, `snowflake-connector-python`, `requests`)
- Automation & CDC: Snowflake Streams, Tasks, External Stages, and SAS Tokens
- CI/CD: GitHub Actions
- Architecture Pattern: Medallion Architecture (Bronze → Silver → Gold)

## ✨ Features

- Fully automated Infrastructure as Code deployment.
- Dynamic SAS token generation for secure Azure-Snowflake integration.
- Medallion data architecture with Bronze, Silver, and Gold layers.
- Automated CDC execution using Snowflake Streams and Task DAGs.
- Semi-structured data handling using `LATERAL FLATTEN`.
- Enterprise healthcare quality and complaints engineering use-case simulation.
