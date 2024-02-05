The purpose of this Terraform module is to create resources in the AWS account that needs to be crawled by Kaleidoscope's AWS Blueprint.

This README describes the usage of this module as well the resources that are created and their need.

# Usage of this module

The ```main.tf``` file shows how to import this module. We use Terraform's concept of local modules for now.

The variables needed by the module and their description can be seen in [the variables file](./kscope_crawl/variables.tf). All of these variables basically are used to customize the names of the created resources. (You can read the details of these resources and their need in the next section). All of the variables have sane default values, except ```bucket_name``` which is mandatory.

The module outputs four variables, which are used to configure the AWS Blueprint in the Kaleidoscope application. You can see the descriptions of the outputs in [the output file](./kscope_crawl/output.tf)

You must output these variables again in your root module, as shown in the ```output``` blocks of [the main file](./main.tf). 

All of the output values will be shown when you run the apply command except the ```secretKey``` value since that is a sensitive value so Terraform by default hides it. You can run ```terraform output --json``` to show all output values in JSON format which will also show the ```secretKey```.

# Infrastructure needed for crawling
The infrastructure needed for crawling can be divided into two parts:

## 1. Data Crawl Infrastructure
Data crawls are the meat of the crawler, they crawl all the resources in the AWS account. For data crawls to work we need the following infrastructure:

1. An AWS IAM user with its access keys. It has the AWS managed `ReadOnlyAccess` policy attached to it which allows it to only read all the resources in the account.

## 2. Event Crawl Infrastructure

Our system supports two distinct setup mechanism to support event crawling.

### 1. Tenant Specific Data & Management CloudTrail trail

Using this option assumes that you do not have an organization level CloudTrail trail. The `aws` terraform application will proceed to setup an account specific CloudTrail trail that is able to capture both Management and Data Events.

To set up this method, set the terraform variable `cloud_trail` as `true` while applying the terraform changes. Its default value is false, which makes the second method default choice.

Additionally, the events are delivered to an AWS S3 bucket. This creates a durable storage for the events.

### 2. Organizational CloudTrail to EventBridge

With this method, events are sourced from AWS CloudTrail at an organizational level and delivered to Amazon EventBridge. This allows for a centralized and organized event stream across your entire AWS organization.

If you are using this approach, you need to set `cloud_trail` as `false`. This will prevent the `aws` terraform application from provisioning an additional CloudTrail trail against the account you are running this terraform - which is the crawl account.

However, when you only execute the `aws` terraform with `cloud_trail` as `false`, you will only receive `Management Events`. No `Data Events` will be captured by the `EventBridge rules`. To receive `Data Events` as well, you need to execute the `aws_organization_trail` terraform app. This should be executed against the *Management Account, not the Crawl Account*. The terraform app will create an additional organizational level CloudTrail trail that captures Data Events.

Both approaches above make use of the default EventBridge for each AWS account, by adding a rule to the account you want to crawl. This rule forwards the events to the SQS queue provisioned by the `aws` terraform app. View the image below for a graphical overview (The image omits a couple of other resources provisioned by `aws` TF for the sake of simplicity in showing the 2 approaches):

![Terraform Configurator drawio](https://github.com/Kaleidoscope-Inc/blueprint-configurator/assets/2979095/18ee9d76-c8c2-4871-984c-4e15133fae58)

Event crawls ingest the events produced by AWS and bind them to the AWS resources crawled by the data crawls to produce a 360 degree view capable of providing more powerful insights. 

For event crawls to work we need the following infrastructure:

1. **S3 bucket**: An S3 bucket that is used by CloudTrail for storing its logs. It also attaches relevant policies allowing CloudTrail to access this bucket.

2. **CloudTrail**: For a non-organizational level CloudTrail setup, a multi region CloudTrail with global service events enabled. For an organizational level trail, the creation of this type of trail is outside the scope of this application. The default setup of an organizational trail will only output Management events. To have Data Events crawled as well, you will need to create an additional organization-level CloudTrail but configured to track Data Events. To set this up, we have provided [aws_organization_trail](../aws_organization_trail).

3. **EventBridge rule**: This rule is required to be created for each account you want to crawl. The rule filters events from CloudTrail to an SQS queue which our crawler is periodically crawling.

4. **SQS**: This queue receives events as described by the EventBridge rule. This is the queue our crawler will keep track of to ingest the latest events.

# Terraform variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
|resource_prefix|string|kscope|The prefix that will be appended to name of all the resources created|
|aws_iam_user|string|crawl-user|The name of the IAM user whose credentials are used by Kaleidoscope's aws crawler to crawl resoures. There is only one policy that we attach to this user, the AWS managed read only policy that allows this user to read any resource.|
|cloudtrail_name|string|trail|The name of the cloudtrail that is used by Kaleidoscope's aws crawler to track the events happening in your account.|
|bucket_name|string||The name of the s3 bucket that is used by cloudtrail to store its log file. Please note that the eventual name of this resoruce is {resource_prefix}-{bucke_name} and it has to be globally unique.|
|aws_sqs_queue|string|trail-queue|AWS's aws crawler polls this queue to get latest event log files|
|create_trail|bool|false|Whether to provision a cloudtrail trail. If this is false, it assumes you are using an Organization level trail in the management account|








