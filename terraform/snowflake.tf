terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.0"
    }
  }
}

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_user
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

# 1. Execute SQL Scripts in sequential order
resource "snowflake_unsafe_execute" "rbac_and_infra" {
  execute = file("${path.module}/../snowflake/01_rbac_and_infra.sql")
}

resource "snowflake_unsafe_execute" "azure_integration" {
  depends_on = [snowflake_unsafe_execute.rbac_and_infra]
  execute    = file("${path.module}/../snowflake/02_azure_integration.sql")
}

resource "snowflake_unsafe_execute" "bronze_ingestion" {
  depends_on = [snowflake_unsafe_execute.azure_integration]
  execute    = file("${path.module}/../snowflake/03_bronze_ingestion.sql")
}

resource "snowflake_unsafe_execute" "transformations" {
  depends_on = [snowflake_unsafe_execute.bronze_ingestion]
  execute    = file("${path.module}/../snowflake/04_transformations.sql")
}

resource "snowflake_unsafe_execute" "cdc_automation" {
  depends_on = [snowflake_unsafe_execute.transformations]
  execute    = file("${path.module}/../snowflake/05_cdc_automation.sql")
}