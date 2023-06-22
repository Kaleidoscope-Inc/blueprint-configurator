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