# AWS Terraform Module

The purpose of this Terraform module is to create resources in the AWS account that needs to be crawled by Kaleidoscope's AWS Blueprint.

This README describes the usage of this module as well the resources that are created and their need.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.9 |

## Variables

[Read more](vars.md)

## Permissions Needed

The IAM user associated with the provided access key must have the following permissions:

- AmazonS3FullAccess
- CloudTrailFullAccess
- AmazonEventBridgeFullAccess
- AmazonSQSFullAccess
- ReadOnlyAccess

## Usage

1. Clone the repository to your local machine.
2. Navigate to the `aws` module directory.
3. Configure the required variables and provider settings in the `variables.tf` and `provider.tf` files.
4. Run `terraform init` to initialize the working directory. Note that the AWS module uses Terraform Cloud as a backend. You will need to modify `./aws/cloud.tf`. If you're using a backend, ensure that you are in the correct workspace.
5. For the next commands, it's mandatory to pass the S3 bucket name as a variable for storing SQS logs. To get the bucket name, perform the following steps:
    1. Run `terraform state list` to get the list of all the states.
    2. Look for a state with `s3-bucket`. Use this state in the next command to show bucket details.
    3. Run `terraform state show <state_name>` to get the bucket name.
    4. Use the bucket name from this information and pass it as a variable in the next commands.
6. Run `terraform plan` to review the planned infrastructure changes.
7. Run `terraform apply` to apply the changes and provision the resources.
8. All of the output values will be shown when you run the apply command except the ```secretKey``` value since that is a sensitive value so Terraform by default hides it. You can run ```terraform output --json``` to show all output values in JSON format which will also show the ```secretKey```. These are to be used in aws blueprint configuration in Kaleidoscope app.

## Data Crawl

### Description

Data crawls are the meat of the crawler, they crawl all the resources in the AWS account. For data crawls to work we need the following infrastructure:

1. An AWS IAM user with its access keys. It has the AWS managed `ReadOnlyAccess` policy attached to it which allows it to only read all the resources in the account.


## Event Crawl

### Description

Event crawls ingest the events produced by AWS and bind them to the AWS resources crawled by the data crawls to produce a 360 degree view capable of providing more powerful insights. 

Our system supports two distinct setup mechanism to support event crawling.

### 1. Tenant Specific Data & Management CloudTrail trail

Using this option assumes that you do not have an organization level CloudTrail trail. The `aws` terraform application will proceed to setup an account specific CloudTrail trail that is able to capture both Management and Data Events.

To set up this method, set the terraform variable `cloudtrail_bucket_name` to a value while applying the terraform changes. Its default value is empty, which makes the second method default choice.

Additionally, the events are delivered to an AWS S3 bucket. This creates a durable storage for the events.

### 2. Organizational CloudTrail to EventBridge

With this method, events are sourced from AWS CloudTrail at an organizational level and delivered to Amazon EventBridge. This allows for a centralized and organized event stream across your entire AWS organization.

The organization cloudtrail only tracks `Management Events`. No `Data Events` will be captured by the `EventBridge rules`. To receive `Data Events` as well, you need to execute the `aws_organization_trail` terraform app. This should be executed against the *Management Account, not the Crawl Account*. The terraform app will create an additional organizational level CloudTrail trail that captures Data Events.

For event crawls to work we need the following infrastructure:

1. **S3 bucket**: An S3 bucket that is used by CloudTrail for storing its logs. It also attaches relevant policies allowing CloudTrail to access this bucket. 

2. **CloudTrail**: For a non-organizational level CloudTrail setup, a multi region CloudTrail with global service events enabled. For an organizational level trail, the creation of this type of trail is outside the scope of this application. The default setup of an organizational trail will only output Management events. To have Data Events crawled as well, you will need to create an additional organization-level CloudTrail but configured to track Data Events. To set this up, we have provided [aws_organization_trail](./aws_organization_trail).

3. **EventBridge rule**: This rule is required to be created for each account you want to crawl. The rule filters events from CloudTrail to an SQS queue which our crawler is periodically crawling.

4. **SQS**: This queue receives events as described by the EventBridge rule. This is the queue our crawler will keep track of to ingest the latest events.

Both approaches above make use of the default EventBridge for each AWS account, by adding a rule to the account you want to crawl. This rule forwards the events to the SQS queue provisioned by the `aws` terraform app. View the image below for a graphical overview (The image omits a couple of other resources provisioned by `aws` TF for the sake of simplicity in showing the 2 approaches):

### Diagram

![Event Crawl Diagram](https://github.com/Kaleidoscope-Inc/blueprint-configurator/assets/2979095/18ee9d76-c8c2-4871-984c-4e15133fae58)


## Cleanup

To destroy the created resources and clean up, run `terraform destroy` in the `aws` module directory.

**Note:** Ensure that you have backed up any important data stored in the provisioned resources before executing the destroy command.







