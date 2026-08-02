terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }

  # Azure Storage State Backend
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-eastus"
    storage_account_name = "sttfstate2026eastus"
    container_name       = "tfstate"
    key                  = "hub-spoke.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}