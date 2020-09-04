terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.24.0"
  features {}
}

resource azurerm_resource_group rg_aks {
  name     = var.rg_aks_name
  location = var.rg_aks_location

  tags = var.tags
}

resource azurerm_network_security_group nsg_aks {
  name                = var.nsg_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name

  tags = var.tags
}

resource azurerm_virtual_network vnet_aks {
  name                = var.vnet_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = var.vnet_aks_address_space
  dns_servers         = var.vnet_aks_dns_server

  subnet {
    name           = var.subnet_aks_name
    address_prefix = var.subnet_aks_address
    security_group = azurerm_network_security_group.nsg_aks.id
  }

  tags = var.tags
}
