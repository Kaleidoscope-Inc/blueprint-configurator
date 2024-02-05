# Terraform Repository

This repository contains Terraform scripts for managing resources on different cloud providers. It consists of two main modules:

## Azure Module

The Azure module provisions Azure resources using Terraform. It creates the following resources:

- An Azure AD application with the display name "kaleidoscope-blueprint", which is used for authentication and access control.
- An Azure resource group with the specified name and location.
- An Azure storage account with a standard tier and locally redundant storage (LRS) replication.
- An Azure storage container with a private access type.
- An Azure storage queue.
- An Azure Monitor diagnostic setting for the storage account, enabling logging for storage read, write, delete operations, and all metrics.

### Outputs

The following outputs are provided:

- `client_id`: The client ID of the Azure AD application.
- `client_secret`: The randomly generated client secret for the Azure AD application.
- `subscription_id`: The ID of the current Azure subscription.
- `tenant_id`: The ID of the Azure AD tenant.
- `owner_object_id`: The object ID of the owner of the Azure AD application.
- `storageAccountName`: The name of the created storage account.
- `storageContainerName`: The name of the created storage container.
- `storageQueueName`: The name of the created storage queue.
- `storageAccountKey`: The primary access key of the created storage account.

## AWS Module

The AWS module provisions AWS resources using Terraform. 

[Read more](./aws/README.md)

## Prerequisites

To use these Terraform scripts, ensure that you have the following prerequisites:

- Terraform installed on your local machine.
- Valid credentials and access keys for the respective cloud providers (Azure and AWS).
- Proper configuration of the Terraform providers for Azure and AWS, including authentication and access permissions.

## Usage

1. Clone the repository to your local machine.
2. Navigate to the respective module directory (`azure` or `aws`).
3. Configure the required variables and provider settings in the `variables.tf` and `provider.tf` files.
4. Run `terraform init` to initialize the working directory.
5. For the next commands its mandatory to pass the S3 bucket name as a variable for storing SQS logs. To get the bucket name perform the following steps:
    1. Run `terraform state list` to get the list of all the states.
    2. Look for a state with `s3-bucket`. Use this state in the next command to show bucket details.
    3. Run `terraform state show <state_name>` to get the bucket name.
    4. Use the bucket name from this information and pass it as a variable in the next commands
6. Run `terraform plan` to review the planned infrastructure changes.
7. Run `terraform apply` to apply the changes and provision the resources.
8. After successful provisioning, the outputs will be displayed. Make note of the relevant information for further use.

## Cleanup

To destroy the created resources and clean up, run `terraform destroy` in the respective module directory.

**Note:** Ensure that you have backed up any important data stored in the provisioned resources before executing the destroy command.

For more information and detailed usage instructions, refer to the specific module's documentation in their respective directories.

