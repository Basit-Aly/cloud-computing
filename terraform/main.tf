# ── Terraform configuration ───────────────────────────────────────────────────
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

# ── Azure provider ────────────────────────────────────────────────────────────
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ── Data source: get current Azure client details (needed for Key Vault) ──────
data "azurerm_client_config" "current" {}

# ── Resource Group: container for all our resources ───────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ── Azure Container Registry: stores our Docker images ───────────────────────
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true  # allows username/password login from pipeline
}

# ── Azure Kubernetes Service: runs our Docker containers ──────────────────────
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "restaurant"

  # Single node pool to keep costs low on student tier
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2als_v2"
  }

  # Use system-assigned managed identity (no service principal needed)
  identity {
    type = "SystemAssigned"
  }
}

# ── Grant AKS permission to pull images from ACR ─────────────────────────────
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true

  depends_on = [
  azurerm_kubernetes_cluster.aks,
  azurerm_container_registry.acr
  ]
}

# ── Azure SQL Server ──────────────────────────────────────────────────────────
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

# ── Allow Azure services to access SQL Server ─────────────────────────────────
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Azure SQL Database ────────────────────────────────────────────────────────
resource "azurerm_mssql_database" "sql_db" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"  # cheapest tier, sufficient for demo
}

# ── Azure Key Vault: stores secrets (DB password, connection string) ──────────
resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Allow the current user to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }

    # Allow pipeline service connection to read secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "ca9934d9-38b6-4d36-8fa4-4ad569f19b71"

    secret_permissions = [
      "Get", "List"
    ]
  }
}


# ── Store DB connection string in Key Vault ───────────────────────────────────
resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "DatabaseUrl"
  key_vault_id = azurerm_key_vault.kv.id

  # Build the pyodbc connection string from our variables
  value = "DRIVER={ODBC Driver 18 for SQL Server};SERVER=${azurerm_mssql_server.sql_server.fully_qualified_domain_name};DATABASE=${var.sql_database_name};UID=${var.sql_admin_username};PWD=${var.sql_admin_password}"
}

# ── Store SQL admin password in Key Vault ─────────────────────────────────────
resource "azurerm_key_vault_secret" "sql_password" {
  name         = "SqlAdminPassword"
  key_vault_id = azurerm_key_vault.kv.id
  value        = var.sql_admin_password
}
