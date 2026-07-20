# Snowflake provider configuration
provider "snowflake" {
  organization_name = "TICRBPW"
  account_name      = "FO21753"
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = "ACCOUNTADMIN"
}