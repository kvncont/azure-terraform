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
  tags     = var.tags
}

resource azurerm_network_security_group nsg_aks {
  name                = var.nsg_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  tags                = var.tags
}

resource azurerm_virtual_network vnet_aks {
  name                = var.vnet_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = var.vnet_aks_address_space
  dns_servers         = var.vnet_aks_dns_server
  tags                = var.tags
}

resource azurerm_subnet subnet_aks {
  name                 = var.subnet_aks_name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  virtual_network_name = var.vnet_aks_name
  address_prefixes     = var.subnet_aks_address
}

resource azurerm_kubernetes_cluster aks {
  name                = var.aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  dns_prefix          = "${var.aks_name}-dns"
  kubernetes_version  = var.aks_kubernetes_version

  default_node_pool {
    name                 = var.aks_default_node_pool_name
    orchestrator_version = var.aks_kubernetes_version
    vm_size              = var.aks_vm_size
    enable_auto_scaling  = true
    type                 = "VirtualMachineScaleSets"
    # availability_zones   = ["1", "2"]
    # sku_tier = Paid
    vnet_subnet_id       = azurerm_subnet.subnet_aks.id

    node_count           = var.aks_node_count_default
    max_count            = var.aks_node_max_count
    min_count            = var.aks_node_min_count
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    network_profile {
      network_plugin    = "azure"
      load_balancer_sku = "Basic"
    }

    kube_dashboard {
      enabled = true
    }
  }
  
  tags = var.tags
}
