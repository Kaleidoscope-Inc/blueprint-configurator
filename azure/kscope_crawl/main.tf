terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "azuread" {
  #Configuration options
}

provider "azurerm" {
  #Configuration options
  features {}
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

resource "random_string" "client_secret" {
  length  = 16
  special = true
}

resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_application" "example" {
  display_name = "kaleidoscope-blueprint"

  owners = [
    data.azurerm_client_config.current.object_id
  ]

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    resource_access {
      id = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
    resource_access {
      id = azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
      type = "Role"
    }
    resource_access {
      id = azuread_service_principal.msgraph.app_role_ids["RoleManagement.Read.All"]
      type = "Role"
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_storage_account" "example" {
  name                     = "k6scopemystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "kaleidoscopeactivitylogscontainer"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "example" {
  name                 = "kaleidoscopeactivitylogsqueue"
  storage_account_name = azurerm_storage_account.example.name
}

locals {
  resourceId = "${azurerm_storage_account.example.id}/blobServices/default"
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_logs" {
  name               = "storage-account-logs"
  target_resource_id = local.resourceId
  storage_account_id = azurerm_storage_account.example.id

  enabled_log {
    category = "StorageRead"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "StorageWrite"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "StorageDelete"
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = false
    }
  }
}

//print client id
output "client_id" {
  value = azuread_application.example.application_id
}

//print client secret
output "client_secret" {
  value = random_string.client_secret.result
}

//print subscription id
output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

//print tenant id
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

//print owner object id
output "owner_object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "storageAccountName" {
  value = azurerm_storage_account.example.name
}

output "storageContainerName" {
  value = azurerm_storage_container.example.name
}

output "storageQueueName" {
  value = azurerm_storage_queue.example.name
}

output "storageAccountKey" {
  value     = azurerm_storage_account.example.primary_access_key
  sensitive = true
}