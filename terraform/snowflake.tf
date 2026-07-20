provider "snowflake" {
  account  = var.snowflake_account
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

# Execute SQL Scripts in sequential order
resource "snowflake_unsafe_execute" "rbac_and_infra" {
  execute = file("${path.module}/../snowflake/01_rbac_and_infra.sql")
  revert  = "SELECT 1;"
}

resource "snowflake_unsafe_execute" "azure_integration" {
  depends_on = [snowflake_unsafe_execute.rbac_and_infra]
  execute    = file("${path.module}/../snowflake/02_azure_integration.sql")
  revert     = "SELECT 1;"
}

resource "snowflake_unsafe_execute" "bronze_ingestion" {
  depends_on = [snowflake_unsafe_execute.azure_integration]
  execute    = file("${path.module}/../snowflake/03_bronze_ingestion.sql")
  revert     = "SELECT 1;"
}

resource "snowflake_unsafe_execute" "transformations" {
  depends_on = [snowflake_unsafe_execute.bronze_ingestion]
  execute    = file("${path.module}/../snowflake/04_transformations.sql")
  revert     = "SELECT 1;"
}

resource "snowflake_unsafe_execute" "cdc_automation" {
  depends_on = [snowflake_unsafe_execute.transformations]
  execute    = file("${path.module}/../snowflake/05_cdc_automation.sql")
  revert     = "SELECT 1;"
}