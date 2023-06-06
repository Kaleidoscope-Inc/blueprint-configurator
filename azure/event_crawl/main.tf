terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "example" {
  name                     = "k6scopemystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "k6scopemycontainer"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "example" {
  name                 = "kscopemyqueue"
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
