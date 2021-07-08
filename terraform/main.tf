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

data azurerm_resource_group rg_vnet_akskratos_imported {
  name = "rg-portal"
}

data azurerm_virtual_network vnet_akskratos_imported {
  name                = "vnet-akskratos-imported"
  resource_group_name = data.azurerm_resource_group.rg_vnet_akskratos_imported.name
}

data azurerm_subnet subnet_akskratos_imported {
  name                 = "subnet-akskratos"
  resource_group_name  = data.azurerm_resource_group.rg_vnet_akskratos_imported.name
  virtual_network_name = data.azurerm_virtual_network.vnet_akskratos_imported.name
}

resource azurerm_resource_group rg_terraform {
  name     = "rg-terraform"
  location = var.primary_location
  tags     = var.tags
}

# resource azurerm_resource_group rg_aks {
#   name     = var.rg_aks_name
#   location = var.rg_aks_location
#   tags     = var.tags
# }

# resource azurerm_network_security_group nsg_aks {
#   name                = var.nsg_aks_name
#   location            = azurerm_resource_group.rg_aks.location
#   resource_group_name = azurerm_resource_group.rg_aks.name
#   tags                = var.tags
# }

# resource azurerm_virtual_network vnet_aks {
#   name                = var.vnet_aks_name
#   location            = azurerm_resource_group.rg_aks.location
#   resource_group_name = azurerm_resource_group.rg_aks.name
#   address_space       = var.vnet_aks_address_space
#   # dns_servers         = var.vnet_aks_dns_server
#   tags = var.tags
# }

# resource azurerm_subnet subnet_aks {
#   name                 = var.subnet_aks_name
#   resource_group_name  = azurerm_resource_group.rg_aks.name
#   virtual_network_name = var.vnet_aks_name
#   address_prefixes     = var.subnet_aks_address

#   depends_on = [
#     azurerm_virtual_network.vnet_aks
#   ]
# }

