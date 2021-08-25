terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.60.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_terraform" {
  name     = "rg-terraform"
  location = var.location
  tags     = var.tags
}

module "cosmosdb" {
  # source                 = "../../modules/services/cosmosdb"
  source                 = "git::https://github.com/kvncont/azure-terraform-modules.git//modules/services/cosmosdb?ref=v0.0.6"
  resource_group_name    = azurerm_resource_group.rg_terraform.name
  location               = azurerm_resource_group.rg_terraform.location
  cosmosdb_account_name  = "kvncont"
  cosmosdb_database_name = "kiwi"
  tags                   = var.tags
}
