# Instructions for Setting Up Remote Backend

A management subscription is required.
A storage account and container will be created in a resource group in that subscription.
This container will hold the Terraform state file for the SOC Demo environment

```bash
push bootstrap

management_subscription_id="<azure_subscription_id_for_terraform_backend_state>"

tee ./bootstrap.tfvars<<_EOF
subscription_id_bootstrap = "$management_subscription_id"
_EOF

chmod +x bootstrap.sh

./bootstrap.sh
```

The script will generate `backend.tf` in the parent directory configured to use the storage container.
This backend configuration will override creation of the default `terraform.tfstate` in the filesystem.
A SAS token with an expiration date 2 years from the date of script execution will be generated.