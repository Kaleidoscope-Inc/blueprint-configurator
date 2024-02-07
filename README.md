# Terraform Repository

This repository contains Terraform scripts to prepare different operational sources to be crawled by Kaleidoscope. It currently has support for Azure and AWS.

## Modules

### Azure Module

[Read more](./azure/kscope_crawl/README.md)

## AWS Module

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
4. Run `terraform init` to initialize the working directory. Note that the AWS module uses Terraform Cloud as a backend. You will need to modify `./aws/cloud.tf`. If you're using a backend ensure that you are in the correct workspace.
5. (This step only applies to AWS) For the next commands its mandatory to pass the S3 bucket name as a variable for storing SQS logs. To get the bucket name perform the following steps:
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

