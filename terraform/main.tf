terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.24.0"
  features {}
}

resource azurerm_resource_group rg_aks {
  name     = "rg-akskratos"
  location = "East US 2"

  tags = {
    env        = "dev"
    created_by = "terraform"
  }
}

resource azurerm_network_security_group nsg_aks {
  name                = "nsg-akskratos"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name

  tags = {
    env        = "dev"
    created_by = "terraform"
  }
}

resource azurerm_virtual_network vnet_aks {
  name                = "vnet-akskratos"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet-akskratos"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg_aks.id
  }

  tags = {
    env        = "dev"
    created_by = "terraform"
  }
}
