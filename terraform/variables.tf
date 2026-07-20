variable "azure_subscription_id" { type = string }
variable "azure_client_id"       { type = string }
variable "azure_client_secret"   { type = string }
variable "azure_tenant_id"       { type = string }
variable "azure_location"        { default = "East US" }
variable "resource_group_name"   { default = "azure-de-project" }

variable "snowflake_account"     { type = string }
variable "snowflake_user"        { type = string }
variable "snowflake_password"    { type = string }