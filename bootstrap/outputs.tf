output "storageacct_resourceid" {
  value = module.storage.resource_id
}

output "container_resourceid" {
  value = module.storage.containers["tfstate"].id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
  value = data.azurerm_client_config.current.client_id
}