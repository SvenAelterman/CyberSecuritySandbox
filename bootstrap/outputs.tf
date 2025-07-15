output "container_resourceid" {
  value = module.storage.containers["tfstate"].id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "user_managed_identity" {
  # NB, since we used count meta-argument to create identity, we need to use index 0 to de-reference
  value = module.userassignedidentity[0].principal_id
}