# Azure Storage Account Setup Script

## Overview

The script sets up an Azure storage account, container, and queue, and enables diagnostic logging and metrics for the storage account. It also provides outputs to retrieve important information about the created resources.

### Terraform Configuration

- The Terraform script specifies the required Azure provider and version.

### Azure Resource Creation

- **Resource Group**: A resource group named "storage-rg" is created in the "eastus" location.
- **Storage Account**: An Azure storage account named "k6scopemystorageaccount" is created within the resource group. It uses the "Standard" tier and "LRS" replication type.
- **Storage Container**: A storage container named "k6scopemycontainer" is created within the storage account. It has private access.
- **Storage Queue**: A storage queue named "kscopemyqueue" is created within the storage account.

### Diagnostic Logging and Metrics

- **Diagnostic Setting**: A diagnostic setting named "storage-account-logs" is created to enable logging for the storage account. It targets the blob service of the storage account and enables logging for categories such as StorageRead, StorageWrite, StorageDelete, and AllMetrics. The retention policy for all logs is set to disabled.

### Outputs

The script provides the following outputs to retrieve information about the created resources:

- **storageAccountName**: The name of the storage account.
- **storageContainerName**: The name of the storage container.
- **storageQueueName**: The name of the storage queue.
- **storageAccountKey**: The primary access key of the storage account. (Sensitive)

