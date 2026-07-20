```markdown
# Azure & Snowflake Medallion Data Engineering Platform

An automated end-to-end cloud data pipeline built with **Terraform (IaC)**, **Azure Blob Storage**, **Snowflake Data Warehouse**, **Python**, and **GitHub Actions**.

---

## 🏥 Domain & Healthcare Relevance: Quality & Global Complaints Engineering

This data platform architecture mimics enterprise healthcare and medical device management systems (such as **Fresenius Medical Care**, **TrackWise**, or **GMQ Quality Management Systems**).

### Healthcare Wing Alignment:
* **Quality Assurance & Regulatory Compliance (Pharmacovigilance & Device Safety)**
* **Global Complaints Management**: Processing incoming customer, clinical, and patient incident complaints regarding medical equipment, dialysis machines, or pharmaceuticals.
* **Auditability & Traceability**: Raw incident payloads land in immutable Azure Blob Storage landing zones, while Snowflake enforces Change Data Capture (CDC) to maintain complete historical lineage required by health authorities (e.g., FDA 21 CFR Part 11, EMA).

---

## 🏗️ Architecture & How It Works


```

┌────────────────────────────────────────────────────────┐
│             GitHub Actions CI/CD Orchestration          │
└───────────┬────────────────────────────────┬───────────┘
│                                │
▼                                ▼
┌───────────────────────┐        ┌───────────────────────┐
│ Pipeline 01 (Azure)   │        │ Pipeline 02 (Snowflake)│
│ Terraform provisions  │        │ Python Ingestion      │
│ Azure Resource Group  │        │ + Multi-Layer DDL     │
│ & Blob Storage        │        │ + Stream/Task CDC     │
└───────────┬───────────┘        └───────────┬───────────┘
│                                │
▼                                ▼
┌───────────────────────┐        ┌───────────────────────┐
│ Azure Blob Storage    │<───────┤ Open REST API /       │
│ Container: 'raw-data' │ (Push) │ Ingestion Script      │
└───────────┬───────────┘        └───────────────────────┘
│
│ (External Stage / SAS Token)
▼
┌────────────────────────────────────────────────────────┐
│              Snowflake Medallion Architecture           │
│  ┌──────────────────────────────────────────────────┐  │
│  │ BRONZE_RAW: RAW_BREWERIES / VARIANT JSON Payload  │  │
│  └────────────────────────┬─────────────────────────┘  │
│                           │ (CDC Stream)               │
│  ┌────────────────────────▼─────────────────────────┐  │
│  │ SILVER_STAGING: DIM_BREWERIES (Parsed Relational)│  │
│  └────────────────────────┬─────────────────────────┘  │
│                           │ (Chained Task)             │
│  ┌────────────────────────▼─────────────────────────┐  │
│  │ GOLD_ANALYTICS: FACT_BREWERY_SUMMARY_BY_STATE    │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘

```

---

## 🛠️ Repository File Structure

```text
.
├── .github/
│   └── workflows/
│       ├── 01-azure-infra.yaml        # Infrastructure as Code deployment
│       └── 02-snowflake-ingest.yaml   # Database DDL & Data Ingestion execution
├── scripts/
│   ├── fetch_and_load.py           # Ingestion engine (API -> Azure Blob -> Snowflake)
│   └── run_snowflake_setup.py      # Multi-statement SQL setup executor
├── snowflake/
│   ├── 01_rbac_and_infra.sql       # Warehouse, Roles, Databases, and Schemas
│   ├── 02_azure_integration.sql    # Stage and File Formats with SAS Tokens
│   ├── 03_bronze_ingestion.sql     # Bronze Landing & External Tables
│   ├── 04_transformations.sql      # Silver & Gold transformations
│   └── 05_cdc_automation.sql       # CDC Streams & Scheduled Task DAG
└── terraform/
    ├── main.tf                     # Azure Provider & Storage Account module
    ├── snowflake.tf                # Snowflake provider declaration
    └── variables.tf                # Input variable declarations

```

---

## 🔐 Required GitHub Secrets Setup

Navigate to your GitHub Repository: **Settings > Secrets and variables > Actions > New repository secret**.

Add the following 8 secrets:

| Secret Name | Description | Example / Value |
| --- | --- | --- |
| `AZURE_CLIENT_ID` | Azure App Service Principal App ID | `c0739d8d-xxxx-xxxx-xxxx-xxxx` |
| `AZURE_CLIENT_SECRET` | Azure Service Principal Client Secret | `0FL8Q~...` |
| `AZURE_TENANT_ID` | Azure Active Directory Tenant ID | `b1362067-xxxx-xxxx-xxxx-xxxx` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `62ae708f-xxxx-xxxx-xxxx-xxxx` |
| `AZURE_RESOURCE_GROUP` | (Optional) Azure Resource Group Name | `azure-de-pipeline-rg` |
| `SNOWFLAKE_ACCOUNT` | Account Identifier (`ORG-ACCOUNT`) | `TICRBPW-FO21753` |
| `SNOWFLAKE_USER` | Admin User | `SUPERMAN` |
| `SNOWFLAKE_PASSWORD` | Account Password | `YourPassword123!` |

---

## 🚀 Execution & Setup Guide

### Step 1: Clone Repository & Push to Private GitHub Repo

```powershell
git clone [https://github.com/](https://github.com/)<YOUR_USERNAME>/azure-snowflake-de-pipeline.git
cd azure-snowflake-de-pipeline

# Configure local git
git branch -M main
git add .
git commit -m "feat: setup azure and snowflake pipeline"
git push -u origin main

```

### Step 2: Run Infrastructure Pipeline (`01-azure-infra.yaml`)

1. Open your GitHub Repository in your browser.
2. Go to the **Actions** tab.
3. Select **`01 - Azure Infrastructure Pipeline`** on the left menu.
4. Click **Run workflow** $\rightarrow$ **Run workflow**.

*Result*: Provisions the Azure Resource Group, Storage Account, and `raw-data` Blob container via Terraform.

### Step 3: Run Snowflake Setup & Ingestion (`02-snowflake-ingest.yaml`)

1. Select **`02 - Snowflake DB & Ingestion Pipeline`** on the left menu.
2. Click **Run workflow** $\rightarrow$ **Run workflow**.

*Result*:

* Dynamically fetches the newly created Azure Blob name and key using Azure CLI.
* Generates a 7-day secure SAS token for Snowflake.
* Builds the Medallion Database, Schemas, Stages, and Tasks in Snowflake.
* Ingests open API data into Azure Blob Storage and executes `COPY INTO` Bronze.
* CDC Tasks run automatically to process Silver and Gold analytics layers.

---

## 🧪 Pipeline Validation (In Snowflake)

Run this verification query in Snowflake Worksheets using `DE_ETL_ROLE`:

```sql
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;

SELECT 'BRONZE' AS LAYER, COUNT(*) AS ROW_COUNT FROM OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES
UNION ALL
SELECT 'SILVER' AS LAYER, COUNT(*) AS ROW_COUNT FROM OPEN_SOURCE_DB.SILVER_STAGING.DIM_BREWERIES
UNION ALL
SELECT 'GOLD' AS LAYER, COUNT(*) AS ROW_COUNT FROM OPEN_SOURCE_DB.GOLD_ANALYTICS.FACT_BREWERY_SUMMARY_BY_STATE;

```

```

```