terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.60.0"
    }
  }
  backend "azurerm" {}
}

provider azurerm {
  features {}
}

resource azurerm_resource_group rg_terraform {
  name     = "rg-terraform"
  location = var.primary_location
  tags     = var.tags
}
