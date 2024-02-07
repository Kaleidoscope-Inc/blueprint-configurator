The purpose of this Terraform module is to create resources in the AWS account that needs to be crawled by Kaleidoscope's AWS Blueprint.

This README describes the usage of this module as well the resources that are created and their need.

# Usage of this module

The ```main.tf``` file shows how to import this module. We use Terraform's concept of local modules for now.

[Read more](vars.md)

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

To set up this method, set the terraform variable `cloudtrail_bucket_name` to a value while applying the terraform changes. Its default value is empty, which makes the second method default choice.

Additionally, the events are delivered to an AWS S3 bucket. This creates a durable storage for the events.

### 2. Organizational CloudTrail to EventBridge

With this method, events are sourced from AWS CloudTrail at an organizational level and delivered to Amazon EventBridge. This allows for a centralized and organized event stream across your entire AWS organization.

The organization cloudtrail only tracks `Management Events`. No `Data Events` will be captured by the `EventBridge rules`. To receive `Data Events` as well, you need to execute the `aws_organization_trail` terraform app. This should be executed against the *Management Account, not the Crawl Account*. The terraform app will create an additional organizational level CloudTrail trail that captures Data Events.

Both approaches above make use of the default EventBridge for each AWS account, by adding a rule to the account you want to crawl. This rule forwards the events to the SQS queue provisioned by the `aws` terraform app. View the image below for a graphical overview (The image omits a couple of other resources provisioned by `aws` TF for the sake of simplicity in showing the 2 approaches):

![Terraform Configurator drawio](https://github.com/Kaleidoscope-Inc/blueprint-configurator/assets/2979095/18ee9d76-c8c2-4871-984c-4e15133fae58)

Event crawls ingest the events produced by AWS and bind them to the AWS resources crawled by the data crawls to produce a 360 degree view capable of providing more powerful insights. 

For event crawls to work we need the following infrastructure:

1. **S3 bucket**: An S3 bucket that is used by CloudTrail for storing its logs. It also attaches relevant policies allowing CloudTrail to access this bucket. 

2. **CloudTrail**: For a non-organizational level CloudTrail setup, a multi region CloudTrail with global service events enabled. For an organizational level trail, the creation of this type of trail is outside the scope of this application. The default setup of an organizational trail will only output Management events. To have Data Events crawled as well, you will need to create an additional organization-level CloudTrail but configured to track Data Events. To set this up, we have provided [aws_organization_trail](../aws_organization_trail).

3. **EventBridge rule**: This rule is required to be created for each account you want to crawl. The rule filters events from CloudTrail to an SQS queue which our crawler is periodically crawling.

4. **SQS**: This queue receives events as described by the EventBridge rule. This is the queue our crawler will keep track of to ingest the latest events.







