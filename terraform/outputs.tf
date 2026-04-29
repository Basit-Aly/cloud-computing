# ── Outputs: values we need after terraform apply ────────────────────────────
# These are printed to the terminal after provisioning completes.
# The pipeline also uses these to know where to push images and deploy.

output "acr_login_server" {
  description = "ACR login server URL (e.g. restaurantacr.azurecr.io)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.acr.admin_username
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.rg.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.kv.name
}
