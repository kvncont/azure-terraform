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
  name                = var.aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  dns_prefix          = "${var.aks_name}-dns"
  kubernetes_version  = var.aks_kubernetes_version

  default_node_pool {
    name                 = var.aks_default_node_pool_name
    orchestrator_version = var.aks_kubernetes_version
    vm_size              = var.aks_vm_size
    enable_auto_scaling  = var.aks_enable_auto_scaling
    type                 = "VirtualMachineScaleSets"
    # availability_zones   = ["1", "2"]
    # sku_tier             = Paid
    # vnet_subnet_id       = azurerm_subnet.subnet_aks.id
    vnet_subnet_id       = data.azurerm_subnet.subnet_akskratos_imported.id

    node_count           = var.aks_node_count_default
    max_count            = var.aks_node_max_count
    min_count            = var.aks_node_min_count
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "Standard"
    # service_cidr       = "10.0.0.0/16"
    # dns_service_ip     = "10.0.0.10"
    # docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count
    ]
  }

  depends_on = [
    azurerm_subnet.subnet_aks
  ]

  tags = var.tags
}

resource azurerm_monitor_action_group mag_aks_gsbd {
  name                = "GSBD"
  resource_group_name = azurerm_resource_group.rg_aks.name
  short_name          = "GSBD"

  email_receiver {
    name          = "sendtodevteam"
    email_address = "kvncont@gmail.com"
    use_common_alert_schema = true
  }
}

resource azurerm_monitor_action_group mag_aks_gpro {
  name                = "GPRO"
  resource_group_name = azurerm_resource_group.rg_aks.name
  short_name          = "GPRO"

  email_receiver {
    name          = "sendtoadminteam"
    email_address = "monedaplay@gmail.com"
    use_common_alert_schema = true
  }
}

resource azurerm_monitor_metric_alert mma_node_status {
  name                = "Nodes in not ready status for akskratos"
  resource_group_name = azurerm_resource_group.rg_aks.name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Action will be triggered when Nodes status are NotReady or Unknown"
  severity            = 0
  auto_mitigate       = false

  criteria {
    metric_namespace = "Insights.Container/Nodes"
    metric_name      = "nodesCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "Status"
      operator = "Include"
      values   = ["NotReady", "unknown"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag_aks_gsbd.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag_aks_gpro.id
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_monitor_action_group.mag_aks_gsbd,
    azurerm_monitor_action_group.mag_aks_gpro
  ]
}

resource azurerm_monitor_metric_alert mma_pod_status {
  name                = "Pods not in ready state for akskratos"
  resource_group_name = azurerm_resource_group.rg_aks.name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Action will be triggered when pods status are Pending, Unknown or Failed"
  severity            = 0
  auto_mitigate       = false

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "PodReadyPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 80

    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "Kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag_aks_gsbd.id
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag_aks_gpro.id
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_monitor_action_group.mag_aks_gsbd,
    azurerm_monitor_action_group.mag_aks_gpro
  ]
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