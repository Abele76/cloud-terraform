terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "b7f30b5d-3efd-45ad-9985-8824b8e55919"
}
