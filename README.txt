.
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD pipeline to trigger IaC & Ingestion
├── terraform/
│   ├── main.tf                     # Azure Storage Account + Container
│   ├── snowflake.tf                # Snowflake DB, Schema, Stage, External Table
│   ├── variables.tf                # Variables declaration
│   └── terraform.tfvars            # Environment configuration
└── scripts/
    └── fetch_and_load.py           # Ingestion script (Fetches Public API -> Azure Blob)