# Usage of this script

This Terraform script defines infrastructure as code to deploy an Azure storage account and an Azure Active Directory (AD) application. It enables diagnostic logging and metrics for the storage account and provides outputs to retrieve important information about the created resources.

## Overview

The script sets up an Azure storage account, container, and queue, and enables diagnostic logging and metrics for the storage account. It also creates an Azure AD application with a display name of "kaleidoscope-blueprint" and assigns an owner based on the `object_id` of the current client configuration. It specifies a required resource access to a specific scope. The script provides outputs to retrieve information about the created resources.

### Terraform Configuration

The script uses the `azurerm` and `azuread` providers to interact with Azure resources, which are defined in the `required_providers` block at the top.

The `azurerm_subscription` and `azurerm_client_config` data sources are used to retrieve information about the current subscription and the client configuration, respectively.

The `random_string` resource generates a random string that will be used as the client secret for the Azure AD application.

### Azure Resource Creation

- **Resource Group**: A resource group named "storage-rg" is created in the "eastus" location.
- **Storage Account**: An Azure storage account named "k6scopemystorageaccount" is created within the resource group. It uses the "Standard" tier and "LRS" replication type.
- **Storage Container**: A storage container named "k6scopemycontainer" is created within the storage account. It has private access.
- **Storage Queue**: A storage queue named "kscopemyqueue" is created within the storage account.
- **Azure AD Application**: An Azure AD application with a display name of "kaleidoscope-blueprint" is created. It assigns an owner based on the `object_id` of the current client configuration and specifies a required resource access to a specific scope.

### Diagnostic Logging and Metrics

A diagnostic setting named "storage-account-logs" is created to enable logging for the storage account. It targets the blob service of the storage account and enables logging for categories such as StorageRead, StorageWrite, StorageDelete, and AllMetrics. The retention policy for all logs is set to disabled.

### Outputs

The script provides the following outputs to retrieve information about the created resources:

- **storageAccountName**: The name of the storage account.
- **storageContainerName**: The name of the storage container.
- **storageQueueName**: The name of the storage queue.
- **storageAccountKey**: The primary access key of the storage account. (Sensitive)
- **azuread_application.example.application_id**: The client ID of the created Azure AD application.
- **random_string.client_secret.result**: The generated client secret for the Azure AD application.
- **data.azurerm_subscription.current.subscription_id**: The ID of the current Azure subscription.
- **data.azurerm_client_config.current.tenant_id**: The ID of the Azure AD tenant associated with the current subscription.
- **data.azurerm_client_config.current.object_id**: The object ID of the owner of the Azure AD application.
