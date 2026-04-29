# ── All input variables for our infrastructure ───────────────────────────────

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region where all resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "restaurant-rg"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, only alphanumeric)"
  type        = string
  default     = "restaurantacr"
}

variable "aks_cluster_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  type        = string
  default     = "restaurant-aks"
}

variable "sql_server_name" {
  description = "Name of the Azure SQL Server (must be globally unique)"
  type        = string
  default     = "restaurant-sql-server"
}

variable "sql_database_name" {
  description = "Name of the Azure SQL Database"
  type        = string
  default     = "restaurant-db"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "restaurantadmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true  # Terraform will never print this in logs
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique)"
  type        = string
  default     = "restaurant-kv"
}
