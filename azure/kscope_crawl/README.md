# Azure Terraform Module

## Overview

The script sets up an Azure storage account, container, and queue, and enables diagnostic logging and metrics for the storage account. It also creates an Azure AD application with a display name of `kaleidoscope-blueprint` and assigns an owner based on the `object_id` of the current client configuration. It specifies a required resource access to a specific scope. The script provides outputs to retrieve information about the created resources.

# Usage of this script

This Terraform script defines infrastructure as code to deploy an Azure storage account and an Azure Active Directory (AD) application. It enables diagnostic logging and metrics for the storage account and provides outputs to retrieve important information about the created resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.9 |


## Permissions Needed

Ensure that the account used to run the Terraform script has the following permissions:

- Contributor role or equivalent permissions on the Azure subscription.
- Application Administrator or Global Administrator role in Azure Active Directory.

## Usage

1. Clone the repository to your local machine.
2. Navigate to the `azure` module directory.
3. Configure the required variables in the `variables.tfvars` file.
4. Run `terraform init` to initialize the Terraform configuration.
5. Run `terraform plan -var-file="variables.tfvars"` to review the planned infrastructure changes.
6. Run `terraform apply -var-file="variables.tfvars"` to apply the configuration and provision the resources.
7. After successful provisioning, the outputs will be displayed. Make note of the relevant information for further use.
8. You can run ```terraform output --json``` to show all output values in JSON format. These are to be used in azure blueprint configuration in Kaleidoscope app.

## Data Crawl

Data crawls are the meat of the crawler, they crawl all the resources in the Azure account. For data crawls to work we need the following infrastructure:

1. **Azure AD Application**: The `azuread_application` resource creates an Azure AD application with a display name of `kaleidoscope-blueprint` and assigns an owner based on the `object_id` of the current client configuration. It assigns these permission roles using MS Graph to the app:
    - `User.Read.All`
    - `Group.Read.All`
    - `RoleManagement.Read.All`

## Event Crawl

Event crawls ingest the events produced by Azure and bind them to the Azure resources crawled by the data crawls to produce a 360 degree view capable of providing more powerful insights. 

For event crawls to work we need the following infrastructure:

- **Resource Group**: A resource group named `kaleidoscope-storage-rg` is created in the `eastus` location.
- **Storage Account**: An Azure storage account named `k6scopemystorageaccount` is created within the resource group. It uses the `Standard` tier and `LRS` replication type.
- **Storage Container**: A storage container named `k6scopemycontainer` is created within the storage account. It has private access.
- **Storage Queue**: A storage queue named `kscopemyqueue` is created within the storage account.


### Diagnostic Logging and Metrics

A diagnostic setting named `kaleidoscope-storage-account-logs` is created to enable logging for the storage account. It targets the blob service of the storage account and enables logging for categories such as StorageRead, StorageWrite, StorageDelete, and AllMetrics. The retention policy for all logs is set to disabled.

### Diagram

![alt text](image-1.png)

## Cleanup

To destroy the created resources and clean up, run `terraform destroy -var-file="variables.tfvars"` in the `azure` module directory.

**Note:** Ensure that you have backed up any important data stored in the provisioned resources before executing the destroy command.