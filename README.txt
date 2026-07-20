# Azure & Snowflake Medallion Data Engineering Platform

An automated end-to-end cloud data pipeline built using **Terraform (Infrastructure as Code)**, **Azure Blob Storage**, **Snowflake Data Warehouse**, **Python**, and **GitHub Actions**.

---

## Domain & Healthcare Relevance: Quality & Global Complaints Engineering

This data platform architecture mimics enterprise healthcare and medical device management systems such as Fresenius Medical Care, TrackWise, and Global Quality Management (GMQ) platforms.

### Healthcare Wing Alignment

- Quality Assurance & Regulatory Compliance (Pharmacovigilance & Device Safety)
- Global Complaints Management for processing customer, clinical, and patient incident complaints related to medical equipment, dialysis machines, or pharmaceuticals.
- Auditability & Traceability through immutable raw payload storage in Azure Blob Storage and Change Data Capture (CDC) processing within Snowflake.
- Designed to align with regulatory requirements such as FDA 21 CFR Part 11 and EMA auditability guidelines.

---

## Architecture Overview

```text
                    GitHub Actions CI/CD
                              |
               --------------------------------
               |                              |
               |                              |
               ▼                              ▼
       Pipeline 01                       Pipeline 02
      (Azure Infra)               (Snowflake & Ingestion)
               |                              |
        Terraform Deploy                Python Ingestion
               |                       + SQL Automation
               |                       + CDC Processing
               |                              |
               ▼                              ▼
      Azure Resource Group              Open REST APIs
               |                              |
               ▼                              |
       Azure Blob Storage <--------------------
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

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── 01-azure-infra.yaml
│       └── 02-snowflake-ingest.yaml
│
├── scripts/
│   ├── fetch_and_load.py
│   └── run_snowflake_setup.py
│
├── snowflake/
│   ├── 01_rbac_and_infra.sql
│   ├── 02_azure_integration.sql
│   ├── 03_bronze_ingestion.sql
│   ├── 04_transformations.sql
│   └── 05_cdc_automation.sql
│
└── terraform/
    ├── main.tf
    ├── snowflake.tf
    └── variables.tf
```

### Description

| File | Purpose |
|------|---------|
| `01-azure-infra.yaml` | Deploys Azure infrastructure using Terraform |
| `02-snowflake-ingest.yaml` | Executes Snowflake setup and ingestion pipelines |
| `fetch_and_load.py` | Extracts API data and loads it into Azure Blob Storage and Snowflake |
| `run_snowflake_setup.py` | Executes multiple Snowflake SQL scripts sequentially |
| `01_rbac_and_infra.sql` | Creates roles, warehouses, databases, and schemas |
| `02_azure_integration.sql` | Creates Azure integrations, stages, and file formats |
| `03_bronze_ingestion.sql` | Creates Bronze ingestion objects and external tables |
| `04_transformations.sql` | Creates Silver and Gold transformation logic |
| `05_cdc_automation.sql` | Creates Streams, Tasks, and CDC automation pipelines |
| `main.tf` | Defines Azure infrastructure resources |
| `snowflake.tf` | Defines Snowflake provider configuration |
| `variables.tf` | Stores Terraform input variables |

---

## Required GitHub Secrets

Navigate to:

```text
Repository
    |
    └── Settings
          |
          └── Secrets and Variables
                 |
                 └── Actions
                        |
                        └── New Repository Secret
```

Add the following secrets.

| Secret Name | Description |
|------------|------------|
| `AZURE_CLIENT_ID` | Azure Service Principal Application ID |
| `AZURE_CLIENT_SECRET` | Azure Service Principal Client Secret |
| `AZURE_TENANT_ID` | Microsoft Entra Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `AZURE_RESOURCE_GROUP` | Resource Group Name |
| `AZURE_LOCATION` | Deployment Region (e.g., `centralindia`) |
| `SNOWFLAKE_ACCOUNT` | Snowflake Account Identifier |
| `SNOWFLAKE_USER` | Snowflake Username |
| `SNOWFLAKE_PASSWORD` | Snowflake Password |

### Example

| Secret | Example Value |
|--------|--------------|
| `AZURE_CLIENT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | `0FL8Q~xxxxxxxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_RESOURCE_GROUP` | `azure-de-pipeline-rg` |
| `AZURE_LOCATION` | `centralindia` |
| `SNOWFLAKE_ACCOUNT` | `ORG-ACCOUNT` |
| `SNOWFLAKE_USER` | `SUPERMAN` |
| `SNOWFLAKE_PASSWORD` | `********` |

---

## Execution Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/<YOUR_USERNAME>/azure-snowflake-de-pipeline.git

cd azure-snowflake-de-pipeline

git branch -M main

git add .

git commit -m "feat: setup azure and snowflake pipeline"

git push -u origin main
```

---

### Step 2: Deploy Azure Infrastructure

Open GitHub and navigate to:

```text
Repository
    |
    └── Actions
            |
            └── 01 - Azure Infrastructure Pipeline
                        |
                        └── Run Workflow
```

#### Pipeline Tasks

- Logs into Azure.
- Deploys the Resource Group.
- Creates the Storage Account.
- Creates the `raw-data` Blob Container.
- Generates Terraform outputs for subsequent pipelines.

#### Resources Created

```text
Azure Subscription
        |
        ▼
 Resource Group
        |
        ▼
 Storage Account
        |
        ▼
   Blob Storage
        |
        ▼
    raw-data
```

---

### Step 3: Execute Snowflake Setup & Data Ingestion

Navigate to:

```text
Repository
    |
    └── Actions
            |
            └── 02 - Snowflake DB & Ingestion Pipeline
                        |
                        └── Run Workflow
```

#### Pipeline Tasks

- Retrieves Storage Account details using Azure CLI.
- Generates a secure 7-day SAS Token.
- Creates Snowflake databases and schemas.
- Creates Storage Integrations, Stages, and File Formats.
- Creates Bronze, Silver, and Gold layers.
- Creates CDC Streams and Tasks.
- Executes Python ingestion scripts.
- Loads API data into Azure Blob Storage.
- Executes `COPY INTO` commands for Bronze ingestion.
- Processes downstream CDC transformations automatically.

---

## End-to-End Workflow

```text
            Open REST APIs
                    |
                    ▼
            Python Extraction
                    |
                    ▼
           Azure Blob Storage
                    |
                    ▼
              External Stage
                    |
                    ▼
                 Bronze
             RAW_BREWERIES
                    |
                  STREAM
                    |
                    ▼
                 Silver
            DIM_BREWERIES
                    |
                   TASK
                    |
                    ▼
                  Gold
     FACT_BREWERY_SUMMARY_BY_STATE
                    |
                    ▼
              Analytical Queries
```

---

## Pipeline Validation

Execute the following query in Snowflake.

```sql
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;

SELECT
    'BRONZE' AS LAYER,
    COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES

UNION ALL

SELECT
    'SILVER' AS LAYER,
    COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.SILVER_STAGING.DIM_BREWERIES

UNION ALL

SELECT
    'GOLD' AS LAYER,
    COUNT(*) AS ROW_COUNT
FROM OPEN_SOURCE_DB.GOLD_ANALYTICS.FACT_BREWERY_SUMMARY_BY_STATE;
```

### Expected Output

```text
+---------+------------+
| LAYER   | ROW_COUNT  |
+---------+------------+
| BRONZE  |    XXX     |
| SILVER  |    XXX     |
| GOLD    |    XXX     |
+---------+------------+
```

---

## Technologies Used

- Azure Blob Storage
- Microsoft Entra ID
- Terraform (Infrastructure as Code)
- Snowflake Data Warehouse
- Snowflake Streams & Tasks
- Python
- GitHub Actions
- REST APIs
- SQL
- CDC (Change Data Capture)
- Medallion Architecture (Bronze → Silver → Gold)

---

## Features

- Fully automated Infrastructure as Code deployment.
- CI/CD-driven Azure and Snowflake provisioning.
- Secure secret management through GitHub Actions.
- Medallion architecture implementation.
- Change Data Capture (CDC) automation using Snowflake Streams and Tasks.
- External Stage integration between Azure Blob Storage and Snowflake.
- End-to-end healthcare complaint and quality management use case simulation.
- Automated ingestion, transformation, and analytics pipeline.

