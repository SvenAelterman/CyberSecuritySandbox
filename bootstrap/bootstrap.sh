#! /env/usr/bin bash

terraform init

terraform plan -out bootstrap.tfplan -var-file ./bootstrap.tfvars
terraform apply "bootstrap.tfplan"

storageacct_resourceid=$(terraform output -raw storageacct_resourceid )
container_resourceid=$(terraform output -raw container_resourceid)

storage_account_rg=$(echo $storageacct_resourceid | cut -d'/' -f5)
storage_account_name=$(echo $storageacct_resourceid | cut -d'/' -f9)
container_name=$(echo $container_resourceid | cut -d'/' -f13)

end_date=$(date -u -d "2 years" '+%Y-%m-%dT%H:%MZ')

storage_account_key=$(az storage account keys list -g $storage_account_rg -n $storage_account_name  --query [0].value -o tsv)
sastoken=$(az storage container generate-sas -n $container_name --account-key $storage_account_key --account-name $storage_account_name --permissions dlrw --expiry $end_date -o tsv)

tee ../backend.tf<<_EOF
terraform {
  backend "azurerm" {
      key  = "soc_demo.tfstate"
      resource_group_name = "$storage_account_rg"
      storage_account_name = "$storage_account_name"
      container_name = "$container_name"
      sas_token = "$sastoken"
  }
}
_EOF