#!/usr/bin/env bash

terraform init

terraform plan -out bootstrap.tfplan -var-file ./bootstrap.tfvars
terraform apply "bootstrap.tfplan"

storageacct_resourceid=$(terraform output -raw storageacct_resourceid )
container_resourceid=$(terraform output -raw container_resourceid)

storage_account_rg=$(echo $storageacct_resourceid | cut -d'/' -f5)
storage_account_name=$(echo $storageacct_resourceid | cut -d'/' -f9)
container_name=$(echo $container_resourceid | cut -d'/' -f13)

tenant_id=$(terraform output -raw tenant_id )
client_id=$(terraform output -raw client_id )

tee ../backend.tf<<_EOF
terraform {
  backend "azurerm" {
      key  = "soc_demo.tfstate"
      resource_group_name = "$storage_account_rg"
      storage_account_name = "$storage_account_name"
      container_name = "$container_name"
      use_azuread_auth     = true
      tenant_id            = "$tenant_id"
      client_id            = "$client_id"
  }
}
_EOF