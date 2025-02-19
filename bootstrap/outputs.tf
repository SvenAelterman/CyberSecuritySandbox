output storageacct_resourceid {
    value = module.storage.resource_id
}

output container_resourceid {
    value = module.storage.containers["tfstate"].id
}