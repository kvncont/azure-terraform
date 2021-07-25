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

# SharedResources

resource "azurerm_resource_group" "rg_terraform" {
  name     = "rg-terraform"
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_security_group" "nsg_terraform" {
  name                = "nsg-terraform"
  location            = azurerm_resource_group.rg_terraform.location
  resource_group_name = azurerm_resource_group.rg_terraform.name
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet_terraform" {
  name                = "vnet-terraform"
  location            = azurerm_resource_group.rg_terraform.location
  resource_group_name = azurerm_resource_group.rg_terraform.name
  address_space       = ["10.0.0.0/8"]
  # dns_servers         = var.vnet_aks_dns_server
  tags = var.tags
}

resource "azurerm_subnet" "subnet_terraform" {
  name                 = "subnet-terraform"
  resource_group_name  = azurerm_resource_group.rg_terraform.name
  virtual_network_name = azurerm_virtual_network.vnet_terraform.name
  address_prefixes     = ["10.100.100.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}
