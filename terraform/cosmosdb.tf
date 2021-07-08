resource azurerm_cosmosdb_account cosmosdb_account_kvncont {
  name                = "kvncont"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.rg_terraform.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover  = false
  enable_free_tier           = true
  analytical_storage_enabled = false

  #   capabilities {
  #     name = "EnableServerless"
  #   }

  consistency_policy {
    consistency_level = "Session"
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
  }

  #   identity {
  #     type = SystemAssigned
  #   }

    # geo_location {
    #   location          = var.failover_location
    #   failover_priority = 1
    # }

    geo_location {
      location          = azurerm_resource_group.rg_terraform.location
      failover_priority = 0
    }

  tags = var.tags
}

resource azurerm_cosmosdb_sql_database cosmosdb_sql_database_kiwi {
  name = "kiwi"
  resource_group_name = azurerm_resource_group.rg_terraform.name
  account_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.name
}

resource azurerm_cosmosdb_sql_container cosmosdb_sql_container_coll_clothes {
  name = "Clothes"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.resource_group_name
  account_name = azurerm_cosmosdb_account.cosmosdb_account_kvncont.name
  database_name = azurerm_cosmosdb_sql_database.cosmosdb_sql_database_kiwi.name
  partition_key_path = "/ClothesId"
  throughput = 400
}

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
