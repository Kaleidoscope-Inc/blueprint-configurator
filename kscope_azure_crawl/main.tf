terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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

resource "random_string" "client_secret" {
  length  = 16
  special = true
}

resource "azuread_application" "example" {
  display_name = "K6Scope Data Crawl App"

  owners = [
    data.azurerm_client_config.current.object_id
  ]

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

//print client id
output "cient_id" {
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