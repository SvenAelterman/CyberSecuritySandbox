# Azure Isolated Sandbox

This code will create an isolated environment to investigate/analyze suspected malicious code.
It will created an isolated Virtual Network, a Windows Server domain controller, a Windows 11 Client, Azure Bastion, and a storage account.

## Requirements

* It requires a Terraform management mode.
* Azure subscription to hold the isolated resources
* **Optional**, Azure subscription to hold the Terraform state

## Instructions

**Optional**, create storage account to hold terraform state. Instructions are [here](./bootstrap/README.md).

```bash
cp demo.tfvars.sample demo.tfvars
```

Edit `demo.tfvars` and insert the required values.

```bash
git clone https://github.com/SvenAelterman/CyberSecuritySandbox.git ./CyberSecuritySandbox
cd CyberSecuritySandbox
terraform init
terraform plan -out demo.tfplan -var-file=demo.tfvars
terraform apply demo.tfplan
```



