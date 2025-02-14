terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
    // TODO: Create backend settings
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}
