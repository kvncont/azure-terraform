# resource "azurerm_network_security_group" "nsg_terraform" {
#   name                = "nsg-terraform"
#   location            = azurerm_resource_group.rg_terraform.location
#   resource_group_name = azurerm_resource_group.rg_terraform.name
#   tags                = var.tags
# }

# resource "azurerm_virtual_network" "vnet_terraform" {
#   name                = "vnet-terraform"
#   location            = azurerm_resource_group.rg_terraform.location
#   resource_group_name = azurerm_resource_group.rg_terraform.name
#   address_space       = ["10.0.0.0/8"]
#   # dns_servers         = var.vnet_aks_dns_server
#   tags = var.tags
# }

# resource "azurerm_subnet" "subnet_terraform" {
#   name                 = "subnet-terraform"
#   resource_group_name  = azurerm_resource_group.rg_terraform.name
#   virtual_network_name = azurerm_virtual_network.vnet_terraform.name
#   address_prefixes     = ["10.100.100.0/24"]
#   service_endpoints    = ["Microsoft.AzureCosmosDB"]
# }

resource "azurerm_cosmosdb_account" "cosmosdb_account_kvncont" {
  name                = "kvncont"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_terraform.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_free_tier                  = true
  enable_automatic_failover         = false
  analytical_storage_enabled        = false
  is_virtual_network_filter_enabled = true
  # public_network_access_enabled     = true

  # IP's to allow access from azure portal
  # https://docs.microsoft.com/es-es/azure/cosmos-db/how-to-configure-firewall?WT.mc_id=Portal-Microsoft_Azure_DocumentDB#connections-from-the-azure-portal
  # ip_range_filter                   = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  #   capabilities {
  #     name = "EnableServerless"
  #   }

  # virtual_network_rule {
  #   id                                   = azurerm_subnet.subnet_terraform.id
  #   ignore_missing_vnet_service_endpoint = false 
  # }
  consistency_policy {
    consistency_level = "Session"
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
  }

  identity {
    type = "SystemAssigned"
  }

  geo_location {
    location          = azurerm_resource_group.rg_terraform.location
    failover_priority = 0
  }

  # geo_location {
  #   location          = var.failover_location
  #   failover_priority = 1
  # }

  # depends_on = [
  #   azurerm_subnet.subnet_terraform,
  # ]

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_sql_database_kiwi" {
  name                = "kiwi"
  resource_group_name = azurerm_resource_group.rg_terraform.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account_kvncont.name
}

# resource azurerm_cosmosdb_sql_container cosmosdb_sql_container_coll_clothes {
#   name = "Clothes"
#   resource_group_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.resource_group_name
#   account_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.name
#   database_name = azurerm_cosmosdb_sql_database.cosmosdb_sql_database_kiwi.name
#   partition_key_path = "/ClothesId"
#   throughput = 400
# }

# resource azurerm_cosmosdb_sql_stored_procedure cosmosdb_sql_stored_procedure_sp_example {
#   name                = "sp_example"
#   resource_group_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.resource_group_name
#   account_name        = azurerm_cosmosdb_account.cosmosdb_account_kvncont.name
#   database_name       = azurerm_cosmosdb_sql_database.cosmosdb_sql_database_kiwi.name
#   container_name      = azurerm_cosmosdb_sql_container.cosmosdb_sql_container_coll_clothes.name

#   body = <<BODY
#       function () { var context = getContext(); var response = context.getResponse(); response.setBody('Hello, World'); }
# BODY
# }

# resource azurerm_cosmosdb_sql_trigger cosmosdb_sql_trigger_example {
#   name         = "test-trigger"
#   container_id = azurerm_cosmosdb_sql_container.cosmosdb_sql_container_coll_clothes.id
#   body         = "function trigger(){}"
#   operation    = "Delete"
#   type         = "Post"
# }
