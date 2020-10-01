terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.24.0"
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
  # dns_servers         = var.vnet_aks_dns_server
  tags                = var.tags
}

resource azurerm_subnet subnet_aks {
  name                 = var.subnet_aks_name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  virtual_network_name = var.vnet_aks_name
  address_prefixes     = var.subnet_aks_address

  depends_on = [
    azurerm_virtual_network.vnet_aks
  ]
}

resource azurerm_log_analytics_workspace law_aks {
  name                = var.law_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  sku                 = "PerGB2018"
  tags                = var.tags
}

# resource azurerm_log_analytics_solution las_aks {
#   solution_name         = "ContainerInsights"
#   location              = azurerm_resource_group.rg_aks.location
#   resource_group_name   = azurerm_resource_group.rg_aks.name
#   workspace_resource_id = azurerm_log_analytics_workspace.law_aks.id
#   workspace_name        = azurerm_log_analytics_workspace.law_aks.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGalleryContainerInsights"
#   }

#   depends_on = [
#     azurerm_log_analytics_workspace.law_aks
#   ]
# }

resource azurerm_kubernetes_cluster aks {
  # (resource arguments)
}

# resource azurerm_monitor_diagnostic_setting ds_aks {
#   name                       = var.diagnostic_setting_name
#   target_source_id           = azurerm_kubernetes_cluster.aks.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law_aks.id

#   dynamic log {
#     for_each = var.diagnostic_setting_log_categories
#     content {
#       category = log.value
#       enabled  = true
#     }
#   }

#   depends_on = [
#     azurerm_log_analytics_workspace.law_aks,
#     azurerm_kubernetes_cluster.aks
#   ]

#   tags = var.tags
# }