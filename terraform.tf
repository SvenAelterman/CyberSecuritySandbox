terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.0"
    }
    // TODO: Create backend settings
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}
