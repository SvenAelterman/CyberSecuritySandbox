terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    // Local state defaults to ./terraform.tfstate
    // if user does not run bootstrap.sh in ./bootstrap/ directory
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}
